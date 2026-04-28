#!/usr/bin/env bash
# Download PACT from GitHub and install it into a target project.

set -euo pipefail

REPO="${PACT_REPO:-Hypho/pact}"
REF="${PACT_REF:-main}"
TARGET="."
MODE="auto"
FORCE="0"

usage() {
  cat <<'EOF'
Usage: install-from-github.sh [--target <path>] [--mode auto|all|claude|codex|cursor] [--ref <git-ref>] [--force]

Examples:
  curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash
  curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
  curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --ref v1.7.0
EOF
}

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
    --ref)
      REF="${2:-}"
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

case "$MODE" in
  auto|all|claude|codex|cursor) ;;
  *)
    echo "Invalid --mode: $MODE" >&2
    usage
    exit 2
    ;;
esac

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need bash
need tar

if command -v curl >/dev/null 2>&1; then
  FETCH=(curl -fsSL)
elif command -v wget >/dev/null 2>&1; then
  FETCH=(wget -qO-)
else
  echo "Missing required command: curl or wget" >&2
  exit 1
fi

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

ARCHIVE_URL="https://github.com/${REPO}/archive/refs/heads/${REF}.tar.gz"
if [[ "$REF" == v* ]]; then
  ARCHIVE_URL="https://github.com/${REPO}/archive/refs/tags/${REF}.tar.gz"
fi

echo "Downloading PACT from ${REPO}@${REF}..."
"${FETCH[@]}" "$ARCHIVE_URL" | tar -xz -C "$TMP_ROOT"

SRC_DIR="$(find "$TMP_ROOT" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
[ -n "$SRC_DIR" ] || {
  echo "Failed to extract PACT archive" >&2
  exit 1
}

ARGS=(--target "$TARGET" --mode "$MODE")
if [ "$FORCE" = "1" ]; then
  ARGS+=(--force)
fi

bash "$SRC_DIR/scripts/install-pact.sh" "${ARGS[@]}"
