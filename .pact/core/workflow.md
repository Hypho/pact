# PACT Workflow Reference
> Stable reference for the core feature flow. Adapter files and user-facing docs may summarize this file, but should not redefine the workflow differently.

---

## Core Flow

```text
pid -> contract -> build -> verify -> ship
```

`scope` is recommended before the first feature and whenever product direction or risk boundaries change. It is not a state-machine phase.

`retro` runs after 3-5 shipped features or when intent drift is suspected.

---

## Phase Reference

| Phase | Entry Condition | Reads | Writes | Stop Conditions |
|-------|-----------------|-------|--------|-----------------|
| `pid` | No active unshipped feature | `state.md`, `boundaries.md`, optional `FDG.md` | `specs/[feature]-pid.md`, `state.md` | high-risk boundary, unresolved dependency, feature too large, large feature plan required |
| `contract` | phase = `pid`; PID Card exists | PID Card, optional PAD | `contracts/[feature].md`, `state.md` | missing PID Card, unresolved PAD ambiguity, contract too large to verify in one loop |
| `build` | phase = `contract`; contract exists and lints | contract, PID Card, constitution, optional PAD | code changes, `state.md` | unconfirmed component plan, boundary risk, contract violation |
| `verify` | phase = `build-complete`; contract exists and lints | contract | `knowledge/[feature]-verify.md`, `state.md` | no real runtime evidence, `FAIL`, `INCONCLUSIVE` |
| `ship` | phase = `verify-pass`; verify record PASS or manual override | verify record, constitution | archived contract, updated `state.md` | test failure, missing manual acceptance, impact not handled |

---

## Guard Mapping

```bash
bash .pact/bin/pact.sh guard pid
bash .pact/bin/pact.sh guard contract
bash .pact/bin/pact.sh guard build
bash .pact/bin/pact.sh guard verify
bash .pact/bin/pact.sh guard ship
```

Equivalent direct script:

```bash
bash .pact/bin/pact-guard.sh <pid|contract|build|verify|ship>
```

---

## Check Mapping

Installed project self-check:

```bash
bash .pact/bin/pact.sh check --project
```

Framework repository self-check:

```bash
bash .pact/bin/pact.sh check
```

Contract lint:

```bash
bash .pact/bin/pact.sh lint-contract <file|--all|--fixtures>
```

Verify lint:

```bash
bash .pact/bin/pact.sh lint-verify <file|--all|--fixtures>
```

Agent entry lint:

```bash
bash .pact/bin/pact.sh lint-agents <file|--all|--fixtures>
```

State validation and controlled state updates:

```bash
bash .pact/bin/pact.sh state validate
bash .pact/bin/pact.sh state enqueue <feature>
bash .pact/bin/pact.sh state set-phase <phase>
bash .pact/bin/pact.sh state complete
bash .pact/bin/pact.sh state fail-verify
```

Stale state diagnostics:

```bash
bash .pact/bin/pact.sh check --stale
```

---

## State Rules

`.pact/state.md` is the v1.x source of truth.

Agents may read `state.md` directly, but machine-critical state updates should use `pact state` commands so phase transitions, duplicate queue/completed entries, unsafe feature names, and verify evidence requirements are checked before writing.

Structured state and queue files are draft-only in v1.x:

```text
.pact/schemas/state.schema.json
.pact/state.example.json
.pact/schemas/queue.schema.json
.pact/queue.example.json
```

Do not create `.pact/state.json` or `.pact/queue.json` as active truth sources unless a future incompatible protocol version explicitly enables them.

The current feature name must exactly match generated file paths:

```text
.pact/specs/[feature]-pid.md
.pact/contracts/[feature].md
.pact/knowledge/[feature]-verify.md
```

Do not infer that a missing artifact is acceptable because it was discussed in the current chat. The file must exist when the phase requires it.

---

## Verification Rules

Verification must use real runtime evidence.

The verify record must contain exactly one strict verdict line:

```text
verdict = PASS
verdict = FAIL
verdict = INCONCLUSIVE
```

`PASS` requires runtime evidence such as `command:`, `output:`, or `result:`.

## Feature Sizing Rules

Each feature should fit one complete `contract -> build -> verify -> ship` loop.

Treat a feature as too large when it matches any of these signals:

- spans 3+ modules
- changes schema and also requires multiple backend/UI/permission/async updates
- likely needs 2+ sessions to complete
- depends on 3+ unfinished features
- produces more than 7 FC entries in the contract
- cannot be described as one independently verifiable user value

When sizing fails, split the feature or create an exec-plan before continuing.

## Reusable Patterns

Use `.pact/knowledge/patterns.md` for durable cross-feature engineering knowledge.

Patterns should be promoted during `ship` or cleaned during `retro`. Do not use it as a story log, debug scratchpad, or replacement for `AGENTS.md`, `constitution.md`, or module handover files.
