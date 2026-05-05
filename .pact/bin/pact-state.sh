#!/bin/bash
# Controlled PACT state operations for the v1.x Markdown state source.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
STATE_FILE="${PACT_STATE_FILE:-$PACT_ROOT/.pact/state.md}"

VALID_PHASES="待开始 pid contract build build-complete verify-pass shipped"

fail() {
  echo "❌ $1" >&2
  exit 1
}

pass() {
  echo "✅ $1"
}

usage() {
  cat <<'EOF'
Usage: bash .pact/bin/pact-state.sh <command> [args]

Commands:
  validate                  Validate state shape and logical consistency
  set-phase <phase>         Move current state to a legal phase
  enqueue <feature>         Add a feature to the queue
  complete                  Mark the current verify-pass feature complete
  fail-verify               Record a FAIL verify result and return to build
  --fixtures                Run state command fixtures
EOF
}

require_state() {
  [ -f "$STATE_FILE" ] || fail "state.md 不存在：$STATE_FILE"
}

normalize_state() {
  sed -e 's/：/:/g' -e 's/\*\*//g' "$STATE_FILE"
}

is_valid_phase() {
  case "$1" in
    "待开始"|"pid"|"contract"|"build"|"build-complete"|"verify-pass"|"shipped") return 0 ;;
    *) return 1 ;;
  esac
}

is_placeholder_feature() {
  [ "${1:-}" = "" ] || [ "$1" = "[名称]" ] || [ "$1" = "[下一个功能]" ] || [ "$1" = "（暂无）" ]
}

trim_value() {
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

validate_feature_name() {
  local feature="$1"
  local label="${2:-feature}"

  is_placeholder_feature "$feature" && fail "${label} 不能为空或占位符：$feature"
  [ "$feature" = "$(printf '%s' "$feature" | trim_value)" ] || fail "${label} 前后不能有空格：$feature"
  if printf '%s' "$feature" | grep -q '[[:cntrl:]]'; then
    fail "${label} 不能包含控制字符"
  fi
  if printf '%s' "$feature" | grep -Eq '[\\/:\*\?"<>\|]'; then
    fail "${label} 包含路径危险字符：$feature"
  fi
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
      if (index($0, "[") > 0 && index($0, "待开始") > 0) {
        print "待开始"
        exit
      }
      if (match($0, /待开始|[A-Za-z-]+/)) {
        print substr($0, RSTART, RLENGTH)
      }
      exit
    }
  '
}

extract_field() {
  local field="$1"
  normalize_state | awk -v field="$field" '
    $0 ~ field "[[:space:]]*:" {
      sub("^.*" field "[[:space:]]*:[[:space:]]*", "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

read_queue() {
  awk '
    /^## 队列/ { in_queue=1; next }
    /^## / && in_queue { in_queue=0 }
    in_queue && /^[[:space:]]*-[[:space:]]+\[[ xX]\][[:space:]]+/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]+\[[ xX]\][[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (line != "" && line != "[下一个功能]") print line
    }
  ' "$STATE_FILE"
}

read_completed() {
  awk '
    /^## 已完成/ { in_completed=1; next }
    /^## / && in_completed { in_completed=0 }
    in_completed && /^\|/ {
      if ($0 ~ /^\|[-[:space:]]+\|/) next
      line=$0
      sub(/^\|[[:space:]]*/, "", line)
      split(line, cols, "|")
      feature=cols[1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", feature)
      if (feature != "" && feature != "功能" && feature != "（暂无）") print feature
    }
  ' "$STATE_FILE"
}

completed_rows() {
  awk '
    /^## 已完成/ { in_completed=1; next }
    /^## / && in_completed { in_completed=0 }
    in_completed && /^\|/ {
      if ($0 ~ /^\|[[:space:]]*功能[[:space:]]*\|/) next
      if ($0 ~ /^\|[-[:space:]]+\|/) next
      line=$0
      sub(/^\|[[:space:]]*/, "", line)
      split(line, cols, "|")
      feature=cols[1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", feature)
      if (feature != "" && feature != "（暂无）") print $0
    }
  ' "$STATE_FILE"
}

load_state() {
  require_state
  FEATURE="$(extract_feature)"
  PHASE="$(extract_phase)"
  STARTED_AT="$(extract_field "开始时间")"
  DOING="$(extract_field "正在做")"
  BLOCKED="$(extract_field "阻塞")"
  [ -n "$FEATURE" ] || fail "无法解析当前功能"
  [ -n "$PHASE" ] || fail "无法解析当前阶段"
  is_valid_phase "$PHASE" || fail "非法阶段：$PHASE"
}

check_unique_stream() {
  local label="$1"
  local duplicates
  duplicates="$(awk 'seen[$0]++ { print $0 }' | sort -u | tr '\n' ' ')"
  [ -z "$duplicates" ] || fail "${label} 存在重复项：${duplicates% }"
}

validate_artifacts() {
  is_placeholder_feature "$FEATURE" && return 0

  case "$PHASE" in
    pid)
      [ -f "$PACT_ROOT/.pact/specs/${FEATURE}-pid.md" ] || fail "state 声明 pid，但 specs/${FEATURE}-pid.md 不存在"
      ;;
    contract|build|build-complete)
      [ -f "$PACT_ROOT/.pact/contracts/${FEATURE}.md" ] || fail "state 声明 ${PHASE}，但 contracts/${FEATURE}.md 不存在"
      bash "$ROOT/.pact/bin/pact-lint-contract.sh" "$PACT_ROOT/.pact/contracts/${FEATURE}.md" >/dev/null
      ;;
    verify-pass)
      local verify="$PACT_ROOT/.pact/knowledge/${FEATURE}-verify.md"
      [ -f "$verify" ] || fail "state 声明 verify-pass，但 knowledge/${FEATURE}-verify.md 不存在"
      bash "$ROOT/.pact/bin/pact-lint-verify.sh" "$verify" >/dev/null
      grep -Eq '^verdict = PASS$|MANUAL OVERRIDE' "$verify" || fail "verify-pass 需要 verdict = PASS 或 MANUAL OVERRIDE"
      ;;
    shipped)
      [ ! -f "$PACT_ROOT/.pact/contracts/${FEATURE}.md" ] || fail "shipped 阶段不应保留 active contract：contracts/${FEATURE}.md"
      ;;
  esac
}

validate_state() {
  load_state

  if ! is_placeholder_feature "$FEATURE"; then
    validate_feature_name "$FEATURE" "current feature"
  fi

  while IFS= read -r item; do
    validate_feature_name "$item" "queue feature"
  done < <(read_queue)

  while IFS= read -r item; do
    validate_feature_name "$item" "completed feature"
  done < <(read_completed)

  read_queue | check_unique_stream "queue"
  read_completed | check_unique_stream "completed"

  if ! is_placeholder_feature "$FEATURE"; then
    if read_queue | grep -Fxq "$FEATURE"; then
      fail "current feature 不能同时出现在 queue：$FEATURE"
    fi
    if read_completed | grep -Fxq "$FEATURE"; then
      fail "current feature 不能同时出现在 completed：$FEATURE"
    fi
  fi

  validate_artifacts
  pass "PACT state validate passed"
}

write_rendered_state() {
  local target="$1"
  local feature="$2"
  local phase="$3"
  local started_at="$4"
  local doing="$5"
  local blocked="$6"
  local queue_file="$7"
  local completed_file="$8"
  local now_text
  now_text="$(date '+%Y-%m-%d %H:%M')"

  {
    echo "# PACT State"
    echo "> 运行时状态数据。状态机规则与文件校验见 CLAUDE.md § 1。"
    echo "> 最后更新：$now_text"
    echo
    echo "---"
    echo
    echo "## 当前"
    echo
    echo '```'
    echo "功能：$feature | 阶段：$phase"
    echo "开始时间：$started_at"
    echo "正在做：$doing"
    echo "阻塞：$blocked"
    echo '```'
    echo
    echo "## 队列"
    echo
    if [ -s "$queue_file" ]; then
      while IFS= read -r item; do
        echo "- [ ] $item"
      done < "$queue_file"
    else
      echo "- [ ] [下一个功能]"
    fi
    echo
    echo "## 已完成（最近 5 条，更早记录见 knowledge/archive/state-history.md）"
    echo
    echo "| 功能 | 开始 | 完成 | 契约 | 测试 | Verify |"
    echo "|------|------|------|------|------|--------|"
    if [ -s "$completed_file" ]; then
      cat "$completed_file"
    else
      echo "| （暂无） | | | | | |"
    fi
  } > "$target"
}

write_state_atomic() {
  local feature="$1"
  local phase="$2"
  local started_at="$3"
  local doing="$4"
  local blocked="$5"
  local queue_file="$6"
  local completed_file="$7"
  local tmp

  tmp="$(mktemp "${STATE_FILE}.tmp.XXXXXX")"
  write_rendered_state "$tmp" "$feature" "$phase" "$started_at" "$doing" "$blocked" "$queue_file" "$completed_file"

  echo "PACT state diff:"
  diff -u "$STATE_FILE" "$tmp" || true

  PACT_STATE_FILE="$tmp" PACT_ROOT="$PACT_ROOT" bash "$ROOT/.pact/bin/pact-state.sh" validate >/dev/null
  mv "$tmp" "$STATE_FILE"
}

copy_queue_to() {
  local target="$1"
  read_queue > "$target"
}

copy_completed_to() {
  local target="$1"
  completed_rows > "$target"
}

legal_transition() {
  local from="$1"
  local to="$2"
  case "$from:$to" in
    "待开始:pid"|"pid:contract"|"contract:build"|"build:build-complete"|"build-complete:verify-pass"|"verify-pass:shipped"|"build-complete:build"|"verify-pass:build") return 0 ;;
    *) return 1 ;;
  esac
}

cmd_set_phase() {
  local next="${1:-}"
  [ -n "$next" ] || fail "缺少目标阶段"
  is_valid_phase "$next" || fail "非法阶段：$next"
  load_state
  legal_transition "$PHASE" "$next" || fail "非法阶段迁移：$PHASE -> $next"

  local tmpdir queue_file completed_file next_feature next_started next_doing next_blocked
  tmpdir="$(mktemp -d)"
  queue_file="$tmpdir/queue"
  completed_file="$tmpdir/completed"
  copy_queue_to "$queue_file"
  copy_completed_to "$completed_file"

  next_feature="$FEATURE"
  next_started="$STARTED_AT"
  next_doing="$DOING"
  next_blocked="$BLOCKED"

  if is_placeholder_feature "$next_feature" && [ "$next" = "pid" ]; then
    [ -s "$queue_file" ] || fail "待开始 -> pid 需要 queue 中存在下一个 feature"
    next_feature="$(head -n 1 "$queue_file")"
    tail -n +2 "$queue_file" > "$tmpdir/queue.next"
    mv "$tmpdir/queue.next" "$queue_file"
    next_started="$(date '+%Y-%m-%d %H:%M')"
    next_doing="创建 PID Card"
    next_blocked="无"
  fi

  validate_feature_name "$next_feature" "current feature"
  write_state_atomic "$next_feature" "$next" "$next_started" "$next_doing" "$next_blocked" "$queue_file" "$completed_file"
  rm -rf "$tmpdir"
  pass "state phase updated: $PHASE -> $next"
}

cmd_enqueue() {
  local feature="${1:-}"
  [ -n "$feature" ] || fail "缺少 feature"
  validate_feature_name "$feature" "queue feature"
  load_state

  if ! is_placeholder_feature "$FEATURE" && [ "$FEATURE" = "$feature" ]; then
    fail "feature 已是 current：$feature"
  fi
  if read_queue | grep -Fxq "$feature"; then
    fail "feature 已在 queue：$feature"
  fi
  if read_completed | grep -Fxq "$feature"; then
    fail "feature 已在 completed：$feature"
  fi

  local tmpdir queue_file completed_file
  tmpdir="$(mktemp -d)"
  queue_file="$tmpdir/queue"
  completed_file="$tmpdir/completed"
  copy_queue_to "$queue_file"
  printf '%s\n' "$feature" >> "$queue_file"
  copy_completed_to "$completed_file"

  write_state_atomic "$FEATURE" "$PHASE" "$STARTED_AT" "$DOING" "$BLOCKED" "$queue_file" "$completed_file"
  rm -rf "$tmpdir"
  pass "feature enqueued: $feature"
}

verify_has_pass() {
  local verify="$1"
  grep -Eq '^verdict = PASS$|MANUAL OVERRIDE' "$verify"
}

verify_has_fail() {
  local verify="$1"
  grep -q '^verdict = FAIL$' "$verify"
}

cmd_complete() {
  load_state
  [ "$PHASE" = "verify-pass" ] || fail "complete 需要当前阶段为 verify-pass，当前是 $PHASE"
  validate_feature_name "$FEATURE" "current feature"

  local verify="$PACT_ROOT/.pact/knowledge/${FEATURE}-verify.md"
  [ -f "$verify" ] || fail "verify 文件不存在：$verify"
  bash "$ROOT/.pact/bin/pact-lint-verify.sh" "$verify" >/dev/null
  verify_has_pass "$verify" || fail "complete 需要 verdict = PASS 或 MANUAL OVERRIDE"

  local tmpdir queue_file completed_file completed_next contract_ref
  tmpdir="$(mktemp -d)"
  queue_file="$tmpdir/queue"
  completed_file="$tmpdir/completed"
  completed_next="$tmpdir/completed.next"
  read_queue | grep -Fxv "$FEATURE" > "$queue_file" || true

  contract_ref=".pact/contracts/archive/${FEATURE}.md"
  if [ -f "$PACT_ROOT/.pact/contracts/${FEATURE}.md" ]; then
    contract_ref=".pact/contracts/${FEATURE}.md"
    echo "⚠️ active contract still exists and should be archived: $contract_ref"
  fi

  {
    echo "| $FEATURE | $STARTED_AT | $(date '+%Y-%m-%d %H:%M') | $contract_ref | see verify | .pact/knowledge/${FEATURE}-verify.md |"
    completed_rows | awk -F'|' -v feature="$FEATURE" '{
      current=$2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)
      if (current != feature) print
    }'
  } | head -n 5 > "$completed_file"

  write_state_atomic "[名称]" "待开始" "" "无" "无" "$queue_file" "$completed_file"
  rm -rf "$tmpdir"
  pass "feature completed: $FEATURE"
}

first_failure_summary() {
  local file="$1"
  awk '
    /^[[:space:]]*(summary|摘要|failure|失败|result|结果)[[:space:]]*:/ {
      print
      exit
    }
  ' "$file"
}

cmd_fail_verify() {
  load_state
  [ "$PHASE" = "build-complete" ] || [ "$PHASE" = "verify-pass" ] || fail "fail-verify 需要当前阶段为 build-complete 或 verify-pass，当前是 $PHASE"
  validate_feature_name "$FEATURE" "current feature"

  local verify="$PACT_ROOT/.pact/knowledge/${FEATURE}-verify.md"
  [ -f "$verify" ] || fail "verify 文件不存在：$verify"
  bash "$ROOT/.pact/bin/pact-lint-verify.sh" "$verify" >/dev/null
  verify_has_fail "$verify" || fail "fail-verify 需要 verify verdict = FAIL"

  local errors_dir stamp error_file summary tmpdir queue_file completed_file
  errors_dir="$PACT_ROOT/.pact/knowledge/errors"
  mkdir -p "$errors_dir"
  stamp="$(date '+%Y%m%d-%H%M%S')"
  error_file="$errors_dir/${FEATURE}-${stamp}.md"
  summary="$(first_failure_summary "$verify")"
  [ -n "$summary" ] || summary="verify verdict = FAIL"

  {
    echo "# Verify Failure: $FEATURE"
    echo
    echo "- feature: $FEATURE"
    echo "- previous_phase: $PHASE"
    echo "- verify: .pact/knowledge/${FEATURE}-verify.md"
    echo "- verdict: FAIL"
    echo "- summary: $summary"
    echo "- recovery: phase returned to build"
  } > "$error_file"

  tmpdir="$(mktemp -d)"
  queue_file="$tmpdir/queue"
  completed_file="$tmpdir/completed"
  copy_queue_to "$queue_file"
  copy_completed_to "$completed_file"

  write_state_atomic "$FEATURE" "build" "$STARTED_AT" "修复 verify FAIL：$summary" "verify FAIL，见 .pact/knowledge/errors/$(basename "$error_file")" "$queue_file" "$completed_file"
  rm -rf "$tmpdir"
  pass "verify failure recorded: $error_file"
}

write_fixture_state() {
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
正在做：fixture
阻塞：无
\`\`\`

## 队列

- [ ] [下一个功能]

## 已完成（最近 5 条，更早记录见 knowledge/archive/state-history.md）

| 功能 | 开始 | 完成 | 契约 | 测试 | Verify |
|------|------|------|------|------|--------|
| （暂无） | | | | | |
EOF
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || fail "state fixture 应通过但失败：$label"
}

expect_failure() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -ne 0 ] || fail "state fixture 应失败但通过：$label"
}

run_fixtures() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  mkdir -p "$tmp/idle"
  write_fixture_state "$tmp/idle" "[名称]" "待开始"
  expect_success "validate idle" env PACT_ROOT="$tmp/idle" bash "$ROOT/.pact/bin/pact-state.sh" validate
  expect_success "enqueue" env PACT_ROOT="$tmp/idle" bash "$ROOT/.pact/bin/pact-state.sh" enqueue "fixture-login"
  expect_failure "duplicate enqueue" env PACT_ROOT="$tmp/idle" bash "$ROOT/.pact/bin/pact-state.sh" enqueue "fixture-login"

  mkdir -p "$tmp/phase/.pact/specs"
  write_fixture_state "$tmp/phase" "[名称]" "待开始"
  env PACT_ROOT="$tmp/phase" bash "$ROOT/.pact/bin/pact-state.sh" enqueue "fixture-login" >/dev/null
  echo "# PID" > "$tmp/phase/.pact/specs/fixture-login-pid.md"
  expect_success "set phase pid" env PACT_ROOT="$tmp/phase" bash "$ROOT/.pact/bin/pact-state.sh" set-phase pid
  expect_failure "illegal phase jump" env PACT_ROOT="$tmp/phase" bash "$ROOT/.pact/bin/pact-state.sh" set-phase build-complete

  mkdir -p "$tmp/fail/.pact/contracts" "$tmp/fail/.pact/knowledge"
  write_fixture_state "$tmp/fail" "fixture-login" "build-complete"
  cp "$ROOT/.pact/tests/fixtures/contract/valid-contract.md" "$tmp/fail/.pact/contracts/fixture-login.md"
  echo "verdict = FAIL" > "$tmp/fail/.pact/knowledge/fixture-login-verify.md"
  expect_success "fail verify" env PACT_ROOT="$tmp/fail" bash "$ROOT/.pact/bin/pact-state.sh" fail-verify

  mkdir -p "$tmp/complete/.pact/knowledge"
  write_fixture_state "$tmp/complete" "fixture-login" "verify-pass"
  cp "$ROOT/.pact/tests/fixtures/verify/valid-pass.md" "$tmp/complete/.pact/knowledge/fixture-login-verify.md"
  expect_success "complete" env PACT_ROOT="$tmp/complete" bash "$ROOT/.pact/bin/pact-state.sh" complete

  pass "state fixtures passed"
}

cmd="${1:-}"
case "$cmd" in
  validate)
    validate_state
    ;;
  set-phase)
    shift
    cmd_set_phase "${1:-}"
    ;;
  enqueue)
    shift
    cmd_enqueue "${1:-}"
    ;;
  complete)
    cmd_complete
    ;;
  fail-verify)
    cmd_fail_verify
    ;;
  --fixtures)
    run_fixtures
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    echo "Unknown PACT state command: $cmd" >&2
    usage
    exit 2
    ;;
esac
