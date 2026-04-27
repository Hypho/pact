#!/bin/bash
# Optional git-aware release check.
# This script is for teams that use git. It does not require GitHub and has no side effects.

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

[ -f VERSION ] || fail "VERSION 不存在"
VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"

if ! echo "$VERSION_VALUE" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  fail "VERSION 格式非法：$VERSION_VALUE"
fi

command -v git >/dev/null 2>&1 || fail "未安装 git，无法执行 git-aware 发布检查"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "当前目录不在 git 仓库中"

if [ -n "$(git status --short)" ]; then
  fail "工作区不干净，请先提交或清理改动"
fi

TAG="v${VERSION_VALUE}"
HEAD_SHA="$(git rev-parse HEAD)"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  TAG_SHA="$(git rev-list -n 1 "$TAG")"
  if [ "$TAG_SHA" != "$HEAD_SHA" ]; then
    fail "$TAG 已存在，但不指向当前 commit"
  fi
  info "$TAG 已存在并指向当前 commit"
else
  info "$TAG 尚不存在，可以在确认后创建"
fi

info "Git-aware 发布检查通过"
