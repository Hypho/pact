#!/bin/bash
# Lint PACT PID Card files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ PID lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  echo "hint: map the feature to a PAD flow Step, set feature type to 主流程 / 辅助 / 管理 / 实验, declare success destination, and list architecture impact."
  return 1
}

lint_pid_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  grep -q '^## 谁在使用？' "$file" || errors+=("missing 谁在使用 section")
  grep -q '^## 他要做什么？' "$file" || errors+=("missing 他要做什么 section")
  grep -q '^## 主流程映射' "$file" || errors+=("missing 主流程映射 section")
  grep -q '^## 架构影响' "$file" || errors+=("missing 架构影响 section")
  grep -q '^## 明确不做' "$file" || errors+=("missing 明确不做 section")

  grep -q 'PAD 业务主流程 Step' "$file" || errors+=("missing PAD flow step field")
  grep -q '功能类型' "$file" || errors+=("missing feature type field")
  grep -q '成功后用户去向' "$file" || errors+=("missing success destination field")
  grep -q '涉及模块' "$file" || errors+=("missing module impact field")
  grep -q '涉及实体' "$file" || errors+=("missing entity impact field")
  grep -q '是否需要 ADR' "$file" || errors+=("missing ADR decision field")

  if ! grep -Eq '功能类型[：:][[:space:]]*(主流程|辅助|管理|实验)' "$file"; then
    errors+=("feature type must be 主流程 / 辅助 / 管理 / 实验")
  fi

  if grep -Eq '功能类型[：:][[:space:]]*(辅助|管理|实验)' "$file"; then
    if ! grep -Eq '服务|暂不映射|不属于主流程|PAD 业务主流程 Step[：:][[:space:]]*S[0-9]+' "$file"; then
      errors+=("non-main feature must explain related flow step or out-of-flow rationale")
    fi
  fi

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

lint_all_pid_cards() {
  local found=0
  local failed=0
  local file

  while IFS= read -r file; do
    found=1
    lint_pid_file "$file" || failed=1
  done < <(find .pact/specs -maxdepth 1 -type f -name '*-pid.md' 2>/dev/null | sort)

  [ "$failed" -eq 0 ] || return 1
  [ "$found" -eq 0 ] && echo "✅ PID lint: no PID files found"
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || {
    echo "❌ PID fixture should pass but failed: $label"
    return 1
  }
}

expect_failure() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  if [ "$code" -eq 0 ]; then
    echo "❌ PID fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid PID" lint_pid_file ".pact/tests/fixtures/pid/valid-pid.md"
  expect_success "valid auxiliary PID" lint_pid_file ".pact/tests/fixtures/pid/valid-auxiliary-pid.md"
  expect_failure "missing flow mapping" lint_pid_file ".pact/tests/fixtures/pid/missing-flow-mapping.md"
  expect_failure "invalid feature type" lint_pid_file ".pact/tests/fixtures/pid/invalid-feature-type.md"
  expect_failure "auxiliary without rationale" lint_pid_file ".pact/tests/fixtures/pid/auxiliary-without-rationale.md"
}

case "${1:-}" in
  --all)
    lint_all_pid_cards
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-pid.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_pid_file "$1"
    ;;
esac

echo "✅ PID lint passed"
