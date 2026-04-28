#!/bin/bash
# Lint PACT verification record files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

fail_file() {
  local file="$1"
  shift
  echo "❌ verify lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  return 1
}

lint_verify_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  local verdict_count
  verdict_count="$(grep -Ec '^verdict = (PASS|FAIL|INCONCLUSIVE)$' "$file" || true)"

  if [ "$verdict_count" -eq 0 ]; then
    errors+=("missing strict verdict line")
  elif [ "$verdict_count" -gt 1 ]; then
    errors+=("verdict appears more than once")
  fi

  local speculative
  speculative="$(grep -Eio '应该|预期|理论上|should|expected|theoretically' "$file" | sort -u | tr '\n' ' ' || true)"
  if [ -n "$speculative" ]; then
    errors+=("contains speculative language: ${speculative% }")
  fi

  if grep -q '^verdict = PASS$' "$file"; then
    if ! grep -Eiq '^[[:space:]]*(output|输出|command|命令|result|结果)[[:space:]]*:' "$file"; then
      errors+=("PASS verdict missing runtime evidence marker")
    fi
  fi

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

lint_all_verify_records() {
  local found=0
  local failed=0
  local file

  while IFS= read -r file; do
    found=1
    lint_verify_file "$file" || failed=1
  done < <(find .pact/knowledge -maxdepth 1 -type f -name '*-verify.md' 2>/dev/null | sort)

  [ "$failed" -eq 0 ] || return 1
  [ "$found" -eq 0 ] && echo "✅ verify lint: no verify files found"
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || {
    echo "❌ verify fixture should pass but failed: $label"
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
    echo "❌ verify fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid PASS" lint_verify_file ".pact/tests/fixtures/verify/valid-pass.md"
  expect_failure "missing verdict" lint_verify_file ".pact/tests/fixtures/verify/missing-verdict.md"
  expect_failure "duplicate verdict" lint_verify_file ".pact/tests/fixtures/verify/duplicate-verdict.md"
  expect_failure "speculative language" lint_verify_file ".pact/tests/fixtures/verify/speculative-language.md"
  expect_failure "PASS without output" lint_verify_file ".pact/tests/fixtures/verify/pass-without-output.md"
}

case "${1:-}" in
  --all)
    lint_all_verify_records
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-verify.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_verify_file "$1"
    ;;
esac

echo "✅ verify lint passed"
