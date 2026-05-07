#!/bin/bash
# Lint optional PACT design attachment files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ design lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  echo "hint: design attachments are optional, but declared attachments need trigger reason and acceptance mapping."
  return 1
}

lint_design_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  local kind="unknown"
  if grep -q '^# Design Brief' "$file"; then
    kind="design"
  elif grep -q '^# Sequence' "$file"; then
    kind="sequence"
  elif grep -q '^# Interaction Brief' "$file"; then
    kind="interaction"
  else
    errors+=("missing supported title: # Design Brief / # Sequence / # Interaction Brief")
  fi

  grep -q '^## 触发原因' "$file" || errors+=("missing 触发原因 section")
  grep -q '^## 验收映射' "$file" || errors+=("missing 验收映射 section")

  if [ "$kind" = "sequence" ]; then
    grep -q 'sequenceDiagram' "$file" || errors+=("sequence attachment missing sequenceDiagram")
    grep -q '^## 关键状态变化' "$file" || errors+=("sequence attachment missing 关键状态变化 section")
  fi

  if [ "$kind" = "interaction" ]; then
    grep -q '^## UI 状态' "$file" || errors+=("interaction attachment missing UI 状态 section")
  fi

  if [ "$kind" = "design" ]; then
    grep -q '^## 用户路径' "$file" || errors+=("design brief missing 用户路径 section")
    grep -q '^## 方案边界' "$file" || errors+=("design brief missing 方案边界 section")
  fi

  if grep -Eq '\[请补充|\[feature\]|\[待填写\]|TODO' "$file"; then
    errors+=("contains template placeholders")
  fi

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

lint_all_design_files() {
  local found=0
  local failed=0
  local file

  while IFS= read -r file; do
    found=1
    lint_design_file "$file" || failed=1
  done < <(find .pact/design -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)

  [ "$failed" -eq 0 ] || return 1
  [ "$found" -eq 0 ] && echo "✅ design lint: no design attachment files found"
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || {
    echo "❌ design fixture should pass but failed: $label"
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
    echo "❌ design fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid design brief" lint_design_file ".pact/tests/fixtures/design/valid-design-brief.md"
  expect_success "valid sequence" lint_design_file ".pact/tests/fixtures/design/valid-sequence.md"
  expect_success "valid interaction" lint_design_file ".pact/tests/fixtures/design/valid-interaction.md"
  expect_failure "missing acceptance mapping" lint_design_file ".pact/tests/fixtures/design/missing-acceptance.md"
  expect_failure "sequence without diagram" lint_design_file ".pact/tests/fixtures/design/sequence-without-diagram.md"
  expect_failure "interaction missing states" lint_design_file ".pact/tests/fixtures/design/interaction-missing-states.md"
}

case "${1:-}" in
  --all)
    lint_all_design_files
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-design.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_design_file "$1"
    ;;
esac

echo "✅ design lint passed"
