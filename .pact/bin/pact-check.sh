#!/bin/bash
# PACT repository self-check.
# Runs lightweight checks that should pass locally and in GitHub Actions.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

MODE="${1:---repo}"

case "$MODE" in
  --repo|--project) ;;
  -h|--help)
    echo "Usage: bash .pact/bin/pact-check.sh [--repo|--project]"
    echo "  --repo     Check the PACT framework repository (default)"
    echo "  --project  Check an installed PACT project without requiring PACT release docs"
    exit 0
    ;;
  *)
    echo "Usage: bash .pact/bin/pact-check.sh [--repo|--project]"
    exit 2
    ;;
esac

fail() {
  echo "❌ $1"
  exit 1
}

info() {
  echo "✅ $1"
}

lint_state_file() {
  local file="$1"
  local norm
  norm="$(sed -e 's/：/:/g' -e 's/\*\*//g' "$file")"

  for field in "功能" "阶段" "开始时间" "正在做" "阻塞"; do
    if ! echo "$norm" | grep -q "${field}[[:space:]]*:"; then
      echo "${file} 缺少 state 字段：${field}"
      return 1
    fi
  done

  local phase_line phase
  phase_line="$(echo "$norm" | awk '/阶段[[:space:]]*:/ { print; exit }')"
  if echo "$phase_line" | grep -q '\['; then
    return 0
  fi

  phase="$(echo "$phase_line" | awk '
    {
      sub(/^.*阶段[[:space:]]*:[[:space:]]*/, "")
      if (match($0, /[A-Za-z-]+|待开始/)) {
        print substr($0, RSTART, RLENGTH)
      }
    }
  ')"

  case "$phase" in
    "待开始"|"pid"|"contract"|"build"|"build-complete"|"verify-pass"|"shipped") ;;
    *)
      echo "${file} 包含非法阶段：${phase:-空}"
      return 1
      ;;
  esac
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || fail "fixture 应通过但失败：${label}"
}

expect_failure() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  if [ "$code" -eq 0 ]; then
    fail "fixture 应失败但通过：${label}"
  fi
}

extract_version() {
  local file="$1"
  grep -m1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' "$file" \
    | sed -E 's/^v//'
}

if [ "$MODE" = "--repo" ]; then
  [ -f VERSION ] || fail "VERSION 不存在"
  VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"

  if ! echo "$VERSION_VALUE" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    fail "VERSION 格式非法：$VERSION_VALUE"
  fi

  README_VERSION="$(extract_version README.md)"
  README_ZH_VERSION="$(extract_version README.zh.md)"
  CLAUDE_VERSION="$(extract_version CLAUDE.md)"

  [ -n "$README_VERSION" ] || fail "README.md 缺少版本号"
  [ -n "$README_ZH_VERSION" ] || fail "README.zh.md 缺少版本号"
  [ -n "$CLAUDE_VERSION" ] || fail "CLAUDE.md 缺少版本号"

  if [ "$README_VERSION" != "$VERSION_VALUE" ] || [ "$README_ZH_VERSION" != "$VERSION_VALUE" ] || [ "$CLAUDE_VERSION" != "$VERSION_VALUE" ]; then
    fail "版本号不一致：VERSION=$VERSION_VALUE README.md=$README_VERSION README.zh.md=$README_ZH_VERSION CLAUDE.md=$CLAUDE_VERSION"
  fi

  if ! grep -q "| v${VERSION_VALUE} |" README.md; then
    fail "README.md 版本历史缺少 v${VERSION_VALUE}"
  fi

  if ! grep -q "| v${VERSION_VALUE} |" README.zh.md; then
    fail "README.zh.md 版本历史缺少 v${VERSION_VALUE}"
  fi

  if [ ! -f CHANGELOG.md ]; then
    fail "CHANGELOG.md 不存在"
  fi

  if ! grep -q "## v${VERSION_VALUE} " CHANGELOG.md; then
    fail "CHANGELOG.md 缺少 v${VERSION_VALUE}"
  fi

  if [ -f ENFORCEMENT_ROADMAP.zh.md ]; then
    fail "ENFORCEMENT_ROADMAP.zh.md 是内部路线草案，不应进入公开仓库"
  fi

  if grep -R "ENFORCEMENT_ROADMAP" README.md README.zh.md CLAUDE.md .pact/core/constitution.md >/dev/null; then
    fail "公开文档仍引用 ENFORCEMENT_ROADMAP"
  fi
fi

lint_state_file ".pact/state.md" || fail ".pact/state.md 结构检查失败"
bash .pact/hooks/check-state.sh

expect_success "idle state lint" lint_state_file ".pact/tests/fixtures/state/idle.md"
expect_success "idle state check" env PACT_STATE_FILE=".pact/tests/fixtures/state/idle.md" bash .pact/hooks/check-state.sh

expect_success "pid missing fixture lint" lint_state_file ".pact/tests/fixtures/state/pid-missing-pid-card.md"
expect_failure "pid missing pid-card" env PACT_STATE_FILE=".pact/tests/fixtures/state/pid-missing-pid-card.md" bash .pact/hooks/check-state.sh

expect_success "contract missing fixture lint" lint_state_file ".pact/tests/fixtures/state/contract-missing-contract.md"
expect_failure "contract missing contract" env PACT_STATE_FILE=".pact/tests/fixtures/state/contract-missing-contract.md" bash .pact/hooks/check-state.sh

expect_failure "invalid phase lint" lint_state_file ".pact/tests/fixtures/state/invalid-phase.md"
expect_failure "verify missing file" env PACT_STATE_FILE=".pact/tests/fixtures/state/verify-pass-missing-verify.md" bash .pact/hooks/check-state.sh

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT
mkdir -p "$TMP_ROOT/.pact/knowledge"
cp ".pact/tests/fixtures/state/verify-pass-missing-verdict.md" "$TMP_ROOT/.pact/state.md"
echo "verdict = FAIL" > "$TMP_ROOT/.pact/knowledge/fixture-verify-missing-verdict-verify.md"
expect_failure "verify missing PASS verdict" env PACT_ROOT="$TMP_ROOT" bash .pact/hooks/check-state.sh

bash .pact/bin/pact-lint-contract.sh --fixtures
bash .pact/bin/pact-lint-verify.sh --fixtures
bash .pact/bin/pact-guard.sh --fixtures
bash .pact/bin/pact-lint-contract.sh --all
bash .pact/bin/pact-lint-verify.sh --all

if [ "$MODE" = "--repo" ]; then
  info "PACT 仓库自检通过：VERSION 一致、公开文档无内部路线引用、state / contract / verify / guard 检查通过"
else
  info "PACT 项目自检通过：state / contract / verify / guard 检查通过"
fi
