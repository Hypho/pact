# PACT Agent Instructions

This repository uses PACT, the Product-Aware Contract Toolkit.

This file is the portable agent entry for Codex, Cursor, Augment, and other tools that read `AGENTS.md`.
Claude Code also has `CLAUDE.md` for Claude-specific startup and slash-command behavior.

If entry files disagree, use `.pact/core/workflow.md` for workflow facts and `.pact/core/constitution.md` for hard constraints.

## Core Workflow

Use the PACT feature flow:

```text
pid -> contract -> build -> verify -> ship
```

For the full workflow reference, read `.pact/core/workflow.md`.

For each feature:
- define intent before implementation
- write behavior contracts before code changes
- build against the contract
- verify with real command output
- ship only after `verdict = PASS` or a documented manual override

## Phase Decision Table

| Current state | Next action |
|---------------|-------------|
| Project facts are still placeholders | Initialize PACT before feature work |
| No active unshipped feature | Run `bash .pact/bin/pact.sh guard pid`, then create a PID Card |
| phase = `pid` and PID Card exists | Run `bash .pact/bin/pact.sh guard contract`, then create the behavior contract |
| phase = `contract` and contract lints | Run `bash .pact/bin/pact.sh guard build`, then implement against the contract |
| phase = `build-complete` | Run `bash .pact/bin/pact.sh guard verify`, then write runtime evidence |
| phase = `verify-pass` | Run `bash .pact/bin/pact.sh guard ship`, then archive the feature |
| Any guard fails | Stop and report the exact reason |

## State Source

`.pact/state.md` is the source of truth for the active feature and phase.

Before changing feature work:
- read `.pact/state.md`
- preserve the feature name exactly when generating file paths
- follow the phase sequence unless the user explicitly instructs otherwise

For machine-critical state updates, prefer:

```bash
bash .pact/bin/pact.sh state validate
bash .pact/bin/pact.sh state enqueue <feature>
bash .pact/bin/pact.sh state set-phase <phase>
bash .pact/bin/pact.sh state complete
bash .pact/bin/pact.sh state fail-verify
```

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
bash .pact/bin/pact.sh check --project
```

For stale or repeated-failure diagnostics:

```bash
bash .pact/bin/pact.sh check --stale
```

For agent entry files, run:

```bash
bash .pact/bin/pact.sh lint-agents --all
```

If the project adopts PACT's release layer with `VERSION` and `CHANGELOG.md`, and the task is release-related:

```bash
bash .pact/bin/pact-release-check.sh
```

## Guard Rules

When entering a main PACT stage, use:

```bash
bash .pact/bin/pact.sh guard pid
bash .pact/bin/pact.sh guard contract
bash .pact/bin/pact.sh guard build
bash .pact/bin/pact.sh guard verify
bash .pact/bin/pact.sh guard ship
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

## Don't / Do

| Don't | Do |
|-------|----|
| Do not infer missing artifacts from the chat. | Check the required `.pact/` file path for the current phase. |
| Do not skip PACT phases. | Run the matching guard before entering a main phase. |
| Do not use speculative language as verification. | Capture real command output in the verify record. |
| Do not keep expanding context to understand everything. | Read the current phase files first; load references only when the phase requires them. |
| Do not publish every small edit. | Release only when the change set has clear release value. |

## Release Rules

Do not publish a version for every small edit.

Only update `VERSION`, README version history, and `CHANGELOG.md` when the change set has clear release value.

Do not create tags, push releases, or modify GitHub Releases without explicit maintainer confirmation.

## Tool Notes

Claude Code users can use `.claude/commands/*.md` slash commands.

Codex and Cursor should follow these instructions through `AGENTS.md` and `.pact/` files rather than assuming `/pact.*` slash commands exist.
