#!/usr/bin/env bash
# Install PACT files into a target project.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install-pact.sh --target <path> [--mode all|claude|codex|cursor] [--force]

Modes:
  all      Install CLAUDE.md, .claude, .pact, AGENTS.md, and .cursor
  claude   Install CLAUDE.md, .claude, and .pact
  codex    Install AGENTS.md and .pact
  cursor   Install .cursor, AGENTS.md, and .pact

Examples:
  scripts/install-pact.sh --target ../my-project
  scripts/install-pact.sh --target ../my-project --mode codex
  scripts/install-pact.sh --target ../my-project --mode all --force

On Windows, prefer scripts/install-pact.ps1 or pass a POSIX path such as /mnt/c/path.
EOF
}

MODE="all"
TARGET=""
FORCE="0"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

[ -n "$TARGET" ] || {
  echo "Missing --target" >&2
  usage
  exit 2
}

case "$MODE" in
  all|claude|codex|cursor) ;;
  *)
    echo "Invalid --mode: $MODE" >&2
    usage
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

normalize_target() {
  local input="$1"
  case "$input" in
  [A-Za-z]:\\*|[A-Za-z]:/*)
    if command -v cygpath >/dev/null 2>&1; then
      cygpath -u "$input"
      return
    fi
    if command -v wslpath >/dev/null 2>&1; then
      wslpath -u "$input"
      return
    fi
    echo "Windows path requires cygpath or wslpath: $input" >&2
    exit 1
    ;;
  [A-Za-z]:*)
    echo "Unsupported Windows path in bash: $input" >&2
    echo "Use a POSIX path such as /mnt/c/path, or run scripts/install-pact.ps1 from PowerShell." >&2
    exit 1
    ;;
  esac
  printf '%s\n' "$input"
}

TARGET_NORM="$(normalize_target "$TARGET")"
TARGET_ABS="$(mkdir -p "$TARGET_NORM" && cd "$TARGET_NORM" && pwd)"

copy_item() {
  local src="$1"
  local dst="$2"
  local dst_path="$TARGET_ABS/$dst"

  [ -e "$ROOT/$src" ] || {
    echo "Missing source: $src" >&2
    exit 1
  }

  if [ -e "$dst_path" ] && [ "$FORCE" != "1" ]; then
    echo "Refusing to overwrite existing path: $dst"
    echo "Use --force to overwrite."
    exit 1
  fi

  if [ -e "$dst_path" ]; then
    rm -rf "$dst_path"
  fi

  mkdir -p "$(dirname "$dst_path")"
  cp -R "$ROOT/$src" "$dst_path"
}

install_claude() {
  copy_item "CLAUDE.md" "CLAUDE.md"
  copy_item ".claude" ".claude"
  copy_item ".pact" ".pact"
}

install_codex() {
  copy_item "AGENTS.md" "AGENTS.md"
  copy_item ".pact" ".pact"
}

install_cursor() {
  copy_item ".cursor" ".cursor"
  copy_item "AGENTS.md" "AGENTS.md"
  copy_item ".pact" ".pact"
}

case "$MODE" in
  all)
    copy_item "CLAUDE.md" "CLAUDE.md"
    copy_item ".claude" ".claude"
    copy_item ".pact" ".pact"
    copy_item "AGENTS.md" "AGENTS.md"
    copy_item ".cursor" ".cursor"
    ;;
  claude) install_claude ;;
  codex) install_codex ;;
  cursor) install_cursor ;;
esac

cat <<EOF
PACT installed.

Target: $TARGET_ABS
Mode:   $MODE

Next:
- Claude Code: run /pact.init, then /pact.scope before the first feature.
- Codex/Cursor: ask the agent to initialize the project using PACT.
- Self-check in installed projects: bash .pact/bin/pact-check.sh --project
EOF
