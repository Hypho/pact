#!/usr/bin/env bash
# Unified PACT command wrapper.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage: bash .pact/bin/pact.sh <command> [args]

Commands:
  check [--repo|--project]          Run PACT checks
  state <validate|set-phase|enqueue|complete|fail-verify>
                                    Validate or update PACT state
  guard <pid|contract|build|verify|ship>
                                    Check whether a PACT stage may start
  lint-contract <file|--all|--fixtures>
                                    Lint behavior contracts
  lint-verify <file|--all|--fixtures>
                                    Lint verify records
  lint-agents <file|--all|--fixtures>
                                    Lint agent instruction entry files
  release-check                     Run optional git-aware release check
  help                              Show this help

Examples:
  bash .pact/bin/pact.sh check --project
  bash .pact/bin/pact.sh state validate
  bash .pact/bin/pact.sh guard build
  bash .pact/bin/pact.sh lint-contract --all
  bash .pact/bin/pact.sh lint-agents --all
EOF
}

cmd="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

case "$cmd" in
  check)
    bash "$ROOT/.pact/bin/pact-check.sh" "$@"
    ;;
  state)
    bash "$ROOT/.pact/bin/pact-state.sh" "$@"
    ;;
  guard)
    bash "$ROOT/.pact/bin/pact-guard.sh" "$@"
    ;;
  lint-contract)
    bash "$ROOT/.pact/bin/pact-lint-contract.sh" "$@"
    ;;
  lint-verify)
    bash "$ROOT/.pact/bin/pact-lint-verify.sh" "$@"
    ;;
  lint-agents)
    bash "$ROOT/.pact/bin/pact-lint-agents.sh" "$@"
    ;;
  release-check)
    bash "$ROOT/.pact/bin/pact-release-check.sh" "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown PACT command: $cmd" >&2
    usage
    exit 2
    ;;
esac
