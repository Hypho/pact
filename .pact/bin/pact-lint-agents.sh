#!/bin/bash
# Lint agent instruction entry files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACT_ROOT="${PACT_ROOT:-$ROOT}"
cd "$PACT_ROOT"

MAX_LINES="${PACT_AGENTS_MAX_LINES:-150}"
MAX_REFS="${PACT_AGENTS_MAX_REFS:-10}"

fail_file() {
  local file="$1"
  shift
  echo "❌ AGENTS lint failed: $file"
  for msg in "$@"; do
    echo "- $msg"
  done
  return 1
}

lint_agents_file() {
  local file="$1"
  local errors=()

  [ -f "$file" ] || fail_file "$file" "file does not exist"
  [ -s "$file" ] || fail_file "$file" "file is empty"

  local line_count
  line_count="$(wc -l < "$file" | tr -d '[:space:]')"
  if [ "$line_count" -gt "$MAX_LINES" ]; then
    errors+=("too long: ${line_count} lines; limit is ${MAX_LINES}")
  fi

  if ! grep -q '\.pact/core/workflow\.md' "$file"; then
    errors+=("missing canonical workflow reference: .pact/core/workflow.md")
  fi

  if ! grep -Eq 'pact\.sh[[:space:]]+guard|pact-guard\.sh' "$file"; then
    errors+=("missing guard command reference")
  fi

  if ! grep -q 'check --project' "$file"; then
    errors+=("missing installed-project check command: check --project")
  fi

  local ref_count
  ref_count="$(grep -Eo '[[:alnum:]_./-]+\.md' "$file" | sort -u | wc -l | tr -d '[:space:]')"
  if [ "$ref_count" -gt "$MAX_REFS" ]; then
    errors+=("too many markdown references: ${ref_count}; limit is ${MAX_REFS}")
  fi

  local dont_count has_dont_do
  dont_count="$(grep -Eic '(^|[[:space:]])(Don'\''t|Do not|don'\''t|do not|不要|禁止|不允许)' "$file" || true)"
  if grep -Eiq "Don'?t[[:space:]]*/[[:space:]]*Do|Do[[:space:]]*/[[:space:]]*Don'?t|不要[[:space:]]*/[[:space:]]*应该|\\|[[:space:]]*Don'?t[[:space:]]*\\|[[:space:]]*Do[[:space:]]*\\|" "$file"; then
    has_dont_do=1
  else
    has_dont_do=0
  fi
  if [ "$dont_count" -ge 5 ] && [ "$has_dont_do" -eq 0 ]; then
    errors+=("contains many prohibitions without a Don't / Do table")
  fi

  if [ "${#errors[@]}" -gt 0 ]; then
    fail_file "$file" "${errors[@]}"
  fi
}

lint_all_agents() {
  local found=0
  local failed=0
  local file

  while IFS= read -r file; do
    found=1
    lint_agents_file "$file" || failed=1
  done < <(find . -path './.git' -prune -o -type f -name 'AGENTS.md' -print | sort)

  [ "$failed" -eq 0 ] || return 1
  if [ "$found" -eq 0 ]; then
    echo "✅ AGENTS lint: no AGENTS.md files found"
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
    echo "❌ AGENTS fixture should pass but failed: $label"
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
    echo "❌ AGENTS fixture should fail but passed: $label"
    return 1
  fi
}

lint_fixtures() {
  expect_success "valid AGENTS" lint_agents_file ".pact/tests/fixtures/agents/valid-agents.md"
  expect_failure "too long" lint_agents_file ".pact/tests/fixtures/agents/too-long.md"
  expect_failure "missing workflow reference" lint_agents_file ".pact/tests/fixtures/agents/missing-workflow-ref.md"
  expect_failure "too many refs" lint_agents_file ".pact/tests/fixtures/agents/too-many-refs.md"
  expect_failure "warnings only" lint_agents_file ".pact/tests/fixtures/agents/warnings-only.md"
}

case "${1:-}" in
  --all)
    lint_all_agents
    ;;
  --fixtures)
    lint_fixtures
    ;;
  "")
    echo "Usage: bash .pact/bin/pact-lint-agents.sh <file|--all|--fixtures>"
    exit 2
    ;;
  *)
    lint_agents_file "$1"
    ;;
esac

echo "✅ AGENTS lint passed"
