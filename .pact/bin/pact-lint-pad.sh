#!/bin/bash
# Lint PACT Product Spine / PAD files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ PAD lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  echo "hint: keep PAD as the Product Spine with product goal, core business flow, feature types, entities, UX rules, and out-of-scope boundaries."
  return 1
}

lint_pad_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  grep -q '^## 产品目标' "$file" || errors+=("missing 产品目标 section")
  grep -q '^## 目标用户与核心场景' "$file" || errors+=("missing 目标用户与核心场景 section")
  grep -q '^## 核心业务主流程' "$file" || errors+=("missing 核心业务主流程 section")
  grep -q '^## 功能类型定义' "$file" || errors+=("missing 功能类型定义 section")
  grep -q '^## 核心实体' "$file" || errors+=("missing 核心实体 section")
  grep -q '^## 体验一致性规则' "$file" || errors+=("missing 体验一致性规则 section")
  grep -q '^## 明确不做' "$file" || errors+=("missing 明确不做 section")

  if ! grep -Eq '^\|[[:space:]]*Step[[:space:]]*\|' "$file"; then
    errors+=("missing core business flow table")
  fi

  for kind in "主流程功能" "辅助功能" "管理功能" "实验功能"; do
    grep -q "$kind" "$file" || errors+=("missing feature type: $kind")
  done

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || {
    echo "❌ PAD fixture should pass but failed: $label"
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
    echo "❌ PAD fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid PAD" lint_pad_file ".pact/tests/fixtures/pad/valid-pad.md"
  expect_failure "missing product goal" lint_pad_file ".pact/tests/fixtures/pad/missing-product-goal.md"
  expect_failure "missing flow" lint_pad_file ".pact/tests/fixtures/pad/missing-flow.md"
  expect_failure "missing feature types" lint_pad_file ".pact/tests/fixtures/pad/missing-feature-types.md"
}

case "${1:-}" in
  --all)
    lint_pad_file ".pact/specs/PAD.md"
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-pad.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_pad_file "$1"
    ;;
esac

echo "✅ PAD lint passed"
