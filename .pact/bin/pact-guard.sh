#!/bin/bash
# Check whether a /pact.* command is allowed to start.
# This script has no side effects: it does not execute commands or modify files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail() {
  echo "❌ $1"
  exit 1
}

pass() {
  echo "✅ $1"
}

STATE_FILE="${PACT_STATE_FILE:-$PACT_ROOT/.pact/state.md}"

normalize_state() {
  sed -e 's/：/:/g' -e 's/\*\*//g' "$STATE_FILE"
}

require_state() {
  [ -f "$STATE_FILE" ] || fail "state.md 不存在：$STATE_FILE"
}

extract_feature() {
  normalize_state | awk '
    /功能[[:space:]]*:/ {
      sub(/^.*功能[[:space:]]*:[[:space:]]*/, "")
      sub(/[[:space:]]*\|.*$/, "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

extract_phase() {
  normalize_state | awk '
    /阶段[[:space:]]*:/ {
      sub(/^.*阶段[[:space:]]*:[[:space:]]*/, "")
      if (match($0, /待开始|[A-Za-z-]+/)) {
        print substr($0, RSTART, RLENGTH)
      }
      exit
    }
  '
}

extract_blocked() {
  normalize_state | awk '
    /阻塞[[:space:]]*:/ {
      sub(/^.*阻塞[[:space:]]*:[[:space:]]*/, "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

lint_state_shape() {
  local norm
  norm="$(normalize_state)"
  for field in "功能" "阶段" "开始时间" "正在做" "阻塞"; do
    echo "$norm" | grep -q "${field}[[:space:]]*:" || fail "state.md 缺少字段：${field}"
  done
}

load_state() {
  require_state
  lint_state_shape
  FEATURE="$(extract_feature)"
  PHASE="$(extract_phase)"
  BLOCKED="$(extract_blocked)"

  [ -n "$FEATURE" ] || fail "无法解析当前功能"
  [ -n "$PHASE" ] || fail "无法解析当前阶段"

  case "$PHASE" in
    "待开始"|"pid"|"contract"|"build"|"build-complete"|"verify-pass"|"shipped") ;;
    *) fail "非法阶段：$PHASE" ;;
  esac
}

is_idle_feature() {
  [ "$FEATURE" = "[名称]" ] || [ "$FEATURE" = "" ]
}

is_unblocked() {
  [ -z "$BLOCKED" ] || [ "$BLOCKED" = "无" ] || [[ "$BLOCKED" == \[* ]]
}

feature_slug() {
  echo "$FEATURE"
}

guard_pid() {
  load_state
  is_unblocked || fail "/pact.pid blocked: 当前阻塞字段不是无"
  if is_idle_feature || [ "$PHASE" = "待开始" ] || [ "$PHASE" = "shipped" ]; then
    pass "/pact.pid allowed: no active feature"
    return
  fi
  fail "/pact.pid blocked: active feature $FEATURE is in $PHASE phase"
}

guard_contract() {
  load_state
  [ "$PHASE" = "pid" ] || fail "/pact.contract blocked: 当前阶段是 $PHASE，不是 pid"
  local pid=".pact/specs/$(feature_slug)-pid.md"
  [ -f "$pid" ] || fail "/pact.contract blocked: PID Card 不存在：$pid"
  pass "/pact.contract allowed: PID Card exists"
}

guard_build() {
  load_state
  [ "$PHASE" = "contract" ] || fail "/pact.build blocked: 当前阶段是 $PHASE，不是 contract"
  local contract=".pact/contracts/$(feature_slug).md"
  [ -f "$contract" ] || fail "/pact.build blocked: contract 不存在：$contract"
  bash "$ROOT/.pact/bin/pact-lint-contract.sh" "$contract" >/dev/null
  pass "/pact.build allowed: contract exists and lint passed"
}

guard_verify() {
  load_state
  [ "$PHASE" = "build-complete" ] || fail "/pact.verify blocked: 当前阶段是 $PHASE，不是 build-complete"
  local contract=".pact/contracts/$(feature_slug).md"
  [ -f "$contract" ] || fail "/pact.verify blocked: contract 不存在：$contract"
  bash "$ROOT/.pact/bin/pact-lint-contract.sh" "$contract" >/dev/null
  pass "/pact.verify allowed: build is complete and contract lint passed"
}

guard_ship() {
  load_state
  [ "$PHASE" = "verify-pass" ] || fail "/pact.ship blocked: 当前阶段是 $PHASE，不是 verify-pass"
  local verify=".pact/knowledge/$(feature_slug)-verify.md"
  [ -f "$verify" ] || fail "/pact.ship blocked: verify 记录不存在：$verify"
  bash "$ROOT/.pact/bin/pact-lint-verify.sh" "$verify" >/dev/null
  if grep -q '^verdict = PASS$' "$verify" || grep -q 'MANUAL OVERRIDE' "$verify"; then
    pass "/pact.ship allowed: verify record passed"
    return
  fi
  fail "/pact.ship blocked: verify 记录缺少 PASS 或 MANUAL OVERRIDE"
}

write_state() {
  local root="$1"
  local feature="$2"
  local phase="$3"
  mkdir -p "$root/.pact"
  cat > "$root/.pact/state.md" <<EOF
# PACT State

## 当前

\`\`\`
功能：$feature | 阶段：$phase
开始时间：2026-04-27 10:00
正在做：guard fixture
阻塞：无
\`\`\`

## 队列

- [ ] [下一个功能]
EOF
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || fail "guard fixture 应通过但失败：$label"
}

expect_failure() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -ne 0 ] || fail "guard fixture 应失败但通过：$label"
}

run_fixtures() {
  GUARD_TMP="$(mktemp -d)"
  trap 'rm -rf "$GUARD_TMP"' EXIT

  mkdir -p "$GUARD_TMP/idle"
  write_state "$GUARD_TMP/idle" "[名称]" "待开始"
  expect_success "pid idle" env PACT_ROOT="$GUARD_TMP/idle" bash "$ROOT/.pact/bin/pact-guard.sh" pid

  mkdir -p "$GUARD_TMP/contract-missing/.pact/specs"
  write_state "$GUARD_TMP/contract-missing" "guard-login" "pid"
  expect_failure "contract missing pid" env PACT_ROOT="$GUARD_TMP/contract-missing" bash "$ROOT/.pact/bin/pact-guard.sh" contract

  mkdir -p "$GUARD_TMP/build-ok/.pact/contracts"
  write_state "$GUARD_TMP/build-ok" "guard-login" "contract"
  cp "$ROOT/.pact/tests/fixtures/contract/valid-contract.md" "$GUARD_TMP/build-ok/.pact/contracts/guard-login.md"
  expect_success "build ok" env PACT_ROOT="$GUARD_TMP/build-ok" bash "$ROOT/.pact/bin/pact-guard.sh" build

  mkdir -p "$GUARD_TMP/build-invalid/.pact/contracts"
  write_state "$GUARD_TMP/build-invalid" "guard-login" "contract"
  cp "$ROOT/.pact/tests/fixtures/contract/missing-fc.md" "$GUARD_TMP/build-invalid/.pact/contracts/guard-login.md"
  expect_failure "build invalid contract" env PACT_ROOT="$GUARD_TMP/build-invalid" bash "$ROOT/.pact/bin/pact-guard.sh" build

  mkdir -p "$GUARD_TMP/verify-ok/.pact/contracts"
  write_state "$GUARD_TMP/verify-ok" "guard-login" "build-complete"
  cp "$ROOT/.pact/tests/fixtures/contract/valid-contract.md" "$GUARD_TMP/verify-ok/.pact/contracts/guard-login.md"
  expect_success "verify ok" env PACT_ROOT="$GUARD_TMP/verify-ok" bash "$ROOT/.pact/bin/pact-guard.sh" verify

  mkdir -p "$GUARD_TMP/ship-ok/.pact/knowledge"
  write_state "$GUARD_TMP/ship-ok" "guard-login" "verify-pass"
  cp "$ROOT/.pact/tests/fixtures/verify/valid-pass.md" "$GUARD_TMP/ship-ok/.pact/knowledge/guard-login-verify.md"
  expect_success "ship ok" env PACT_ROOT="$GUARD_TMP/ship-ok" bash "$ROOT/.pact/bin/pact-guard.sh" ship

  mkdir -p "$GUARD_TMP/ship-missing/.pact/knowledge"
  write_state "$GUARD_TMP/ship-missing" "guard-login" "verify-pass"
  cp "$ROOT/.pact/tests/fixtures/verify/missing-verdict.md" "$GUARD_TMP/ship-missing/.pact/knowledge/guard-login-verify.md"
  expect_failure "ship missing verdict" env PACT_ROOT="$GUARD_TMP/ship-missing" bash "$ROOT/.pact/bin/pact-guard.sh" ship

  pass "guard fixtures passed"
}

case "${1:-}" in
  pid) guard_pid ;;
  contract) guard_contract ;;
  build) guard_build ;;
  verify) guard_verify ;;
  ship) guard_ship ;;
  --fixtures) run_fixtures ;;
  *)
    echo "Usage: bash .pact/bin/pact-guard.sh <pid|contract|build|verify|ship|--fixtures>"
    exit 2
    ;;
esac
