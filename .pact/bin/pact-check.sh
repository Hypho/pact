#!/bin/bash
# PACT repository self-check.
# Runs lightweight checks that should pass locally and in GitHub Actions.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() {
  echo "❌ $1"
  exit 1
}

info() {
  echo "✅ $1"
}

extract_version() {
  local file="$1"
  grep -m1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' "$file" \
    | sed -E 's/^v//'
}

README_VERSION="$(extract_version README.md)"
README_ZH_VERSION="$(extract_version README.zh.md)"
CLAUDE_VERSION="$(extract_version CLAUDE.md)"

[ -n "$README_VERSION" ] || fail "README.md 缺少版本号"
[ -n "$README_ZH_VERSION" ] || fail "README.zh.md 缺少版本号"
[ -n "$CLAUDE_VERSION" ] || fail "CLAUDE.md 缺少版本号"

if [ "$README_VERSION" != "$README_ZH_VERSION" ] || [ "$README_VERSION" != "$CLAUDE_VERSION" ]; then
  fail "版本号不一致：README.md=$README_VERSION README.zh.md=$README_ZH_VERSION CLAUDE.md=$CLAUDE_VERSION"
fi

if ! grep -q "| v${README_VERSION} |" README.md; then
  fail "README.md 版本历史缺少 v${README_VERSION}"
fi

if ! grep -q "| v${README_VERSION} |" README.zh.md; then
  fail "README.zh.md 版本历史缺少 v${README_VERSION}"
fi

if [ -f ENFORCEMENT_ROADMAP.zh.md ]; then
  fail "ENFORCEMENT_ROADMAP.zh.md 是内部路线草案，不应进入公开仓库"
fi

if grep -R "ENFORCEMENT_ROADMAP" README.md README.zh.md CLAUDE.md .pact/core/constitution.md >/dev/null; then
  fail "公开文档仍引用 ENFORCEMENT_ROADMAP"
fi

bash .pact/hooks/check-state.sh

info "PACT 自检通过：版本一致、公开文档无内部路线引用、state 检查通过"
