#!/bin/bash
# Lint PACT behavior contract files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ contract lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  return 1
}

lint_contract_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  if ! grep -Eq '(^|[^A-Za-z])FC-[0-9]+' "$file"; then
    errors+=("missing FC entries")
  fi

  if ! grep -Eq '明确不做|Out of Scope' "$file"; then
    errors+=("missing 明确不做 / Out of Scope")
  fi

  if grep -Eq '\\[请补充|\\[功能名\\]|\\[待填写\\]|TODO' "$file"; then
    errors+=("contains template placeholders")
  fi

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

lint_all_contracts() {
  local found=0
  local failed=0
  local file

  while IFS= read -r file; do
    found=1
    lint_contract_file "$file" || failed=1
  done < <(find .pact/contracts .pact/contracts/archive -maxdepth 1 -type f -name '*.md' ! -name '.gitkeep' 2>/dev/null | sort)

  [ "$failed" -eq 0 ] || return 1
  [ "$found" -eq 0 ] && echo "✅ contract lint: no contract files found"
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || {
    echo "❌ contract fixture should pass but failed: $label"
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
    echo "❌ contract fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid contract" lint_contract_file ".pact/tests/fixtures/contract/valid-contract.md"
  expect_failure "missing FC" lint_contract_file ".pact/tests/fixtures/contract/missing-fc.md"
  expect_failure "missing out of scope" lint_contract_file ".pact/tests/fixtures/contract/missing-out-of-scope.md"
  expect_failure "template placeholder" lint_contract_file ".pact/tests/fixtures/contract/template-placeholder.md"
}

case "${1:-}" in
  --all)
    lint_all_contracts
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-contract.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_contract_file "$1"
    ;;
esac

echo "✅ contract lint passed"
