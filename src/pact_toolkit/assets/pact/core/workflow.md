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
| `pid` | No active unshipped feature | `state.md`, `boundaries.md`, optional `FDG.md` | `specs/[feature]-pid.md`, `state.md` | high-risk boundary, unresolved dependency, large feature plan required |
| `contract` | phase = `pid`; PID Card exists | PID Card, optional PAD | `contracts/[feature].md`, `state.md` | missing PID Card, unresolved PAD ambiguity |
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

---

## State Rules

`.pact/state.md` is the v1.x source of truth.

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

