#!/bin/bash
# Lint PACT Architecture Spine files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ architecture lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  echo "hint: keep architecture.md as the Architecture Spine with module boundaries, entity ownership, state ownership, write boundaries, dependency direction, and ADR triggers."
  return 1
}

lint_architecture_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  grep -q '^## 架构原则' "$file" || errors+=("missing 架构原则 section")
  grep -q '^## 模块边界' "$file" || errors+=("missing 模块边界 section")
  grep -q '^## 核心实体归属' "$file" || errors+=("missing 核心实体归属 section")
  grep -q '^## 状态机归属' "$file" || errors+=("missing 状态机归属 section")
  grep -q '^## 权限判断位置' "$file" || errors+=("missing 权限判断位置 section")
  grep -q '^## 数据写入边界' "$file" || errors+=("missing 数据写入边界 section")
  grep -q '^## 依赖方向' "$file" || errors+=("missing 依赖方向 section")
  grep -q '^## ADR 触发条件' "$file" || errors+=("missing ADR 触发条件 section")

  if ! grep -Eq '^\|[[:space:]]*模块[[:space:]]*\|' "$file"; then
    errors+=("missing module boundary table")
  fi

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
    echo "❌ architecture fixture should pass but failed: $label"
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
    echo "❌ architecture fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid architecture" lint_architecture_file ".pact/tests/fixtures/architecture/valid-architecture.md"
  expect_failure "missing module boundaries" lint_architecture_file ".pact/tests/fixtures/architecture/missing-module-boundaries.md"
  expect_failure "missing ADR triggers" lint_architecture_file ".pact/tests/fixtures/architecture/missing-adr-triggers.md"
}

case "${1:-}" in
  --all)
    lint_architecture_file ".pact/core/architecture.md"
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-architecture.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_architecture_file "$1"
    ;;
esac

echo "✅ architecture lint passed"
