# PACT Agent Instructions

This repository uses PACT, the Product-Aware Contract Toolkit.

Follow these rules when working in this project.

## Core Workflow

Use the PACT feature flow:

```text
pid -> contract -> build -> verify -> ship
```

For each feature:
- define intent before implementation
- write behavior contracts before code changes
- build against the contract
- verify with real command output
- ship only after `verdict = PASS` or a documented manual override

## State Source

`.pact/state.md` is the source of truth for the active feature and phase.

Before changing feature work:
- read `.pact/state.md`
- preserve the feature name exactly when generating file paths
- follow the phase sequence unless the user explicitly instructs otherwise

## Files

Expected generated files:

```text
.pact/specs/[feature]-pid.md
.pact/contracts/[feature].md
.pact/knowledge/[feature]-verify.md
```

Completed contracts move to:

```text
.pact/contracts/archive/
```

## Checks

Run this after changing PACT files:

```bash
bash .pact/bin/pact-check.sh --project
```

If the project adopts PACT's release layer with `VERSION` and `CHANGELOG.md`, and the task is release-related:

```bash
bash .pact/bin/pact-release-check.sh
```

## Guard Rules

When entering a main PACT stage, use:

```bash
bash .pact/bin/pact-guard.sh pid
bash .pact/bin/pact-guard.sh contract
bash .pact/bin/pact-guard.sh build
bash .pact/bin/pact-guard.sh verify
bash .pact/bin/pact-guard.sh ship
```

If a guard fails, stop and report the reason instead of bypassing it.

## Verification Rules

Do not claim a feature is verified without real output.

Verify records must contain exactly one strict verdict line:

```text
verdict = PASS
verdict = FAIL
verdict = INCONCLUSIVE
```

For `PASS`, include runtime evidence such as `command:`, `output:`, `result:`, `命令:`, `输出:`, or `结果:`.

## Release Rules

Do not publish a version for every small edit.

Only update `VERSION`, README version history, and `CHANGELOG.md` when the change set has clear release value.

Do not create tags, push releases, or modify GitHub Releases without explicit maintainer confirmation.

## Tool Notes

Claude Code users can use `.claude/commands/*.md` slash commands.

Codex and Cursor should follow these instructions through `AGENTS.md` and `.pact/` files rather than assuming `/pact.*` slash commands exist.
