# PACT Prompts for Codex, Cursor, and Other Agents

Use these prompts when your tool does not expose Claude Code `/pact.*` slash commands.

Each prompt assumes the project contains:

```text
.pact/
AGENTS.md
```

For Cursor, also use:

```text
.cursor/rules/pact.mdc
```

If the current directory or a parent module contains a local `AGENTS.md`, read the nearest one first, then read the root `AGENTS.md` and `.pact/state.md`. Root `AGENTS.md` is the portable PACT entry; `.pact/core/workflow.md` is the workflow source of truth.

---

## Initialize

```text
Initialize this project using PACT.

Read AGENTS.md and .pact/state.md first.
If a nearer module-level AGENTS.md exists, read it before the root AGENTS.md.
Create or update:
- .pact/core/constitution.md
- .pact/specs/PAD.md
- .pact/state.md

Do not start feature implementation.
After initialization, summarize missing product facts that need human confirmation.
```

---

## Scope Assessment

```text
Run the PACT scope assessment for this project.

Read:
- .pact/core/constitution.md
- .pact/scope/boundaries.md

Write or update:
- .pact/scope/fitness.md

Output one of:
- PACT-only
- PACT + specialist review
- Do not use PACT alone

If information is insufficient, mark the relevant boundary as Unknown instead of No.
Do not generate FDG unless I explicitly provide 3+ known features and ask for dependency planning.
```

---

## PID

```text
Create a PACT PID Card for the feature: [feature name].

Before writing:
- read .pact/state.md
- read the nearest AGENTS.md if working inside a module with local instructions
- run or apply the equivalent of: bash .pact/bin/pact.sh guard pid
- check .pact/scope/boundaries.md
- read .pact/specs/FDG.md only if it exists

Write:
- .pact/specs/[feature-name]-pid.md

Update:
- .pact/state.md phase to pid
- current feature name exactly as used in generated file paths

Stop if a high-risk boundary is detected and ask for a decision.
```

---

## Contract

```text
Generate the PACT behavior contract for the current feature.

Before writing:
- read .pact/state.md
- read the nearest AGENTS.md if working inside a module with local instructions
- run or apply the equivalent of: bash .pact/bin/pact.sh guard contract
- read .pact/specs/[current-feature]-pid.md
- read .pact/specs/PAD.md if it exists

Write:
- .pact/contracts/[current-feature].md

The contract must include:
- FC entries
- NF entries where relevant
- explicit out-of-scope boundaries

Do not keep template placeholders.
Update .pact/state.md phase to contract.
```

---

## Build

```text
Build the current feature against the PACT contract.

Before implementation:
- read .pact/state.md
- read the nearest AGENTS.md if working inside a module with local instructions
- run or apply the equivalent of: bash .pact/bin/pact.sh guard build
- read .pact/contracts/[current-feature].md
- read .pact/specs/[current-feature]-pid.md
- read .pact/core/constitution.md

First produce a component plan and wait for confirmation.
Then implement component by component.
After each component, check:
- technical constraints
- PAD consistency
- contract coverage
- runtime boundary risks

When complete, update .pact/state.md phase to build-complete.
```

---

## Verify

```text
Verify the current feature using PACT.

Before verification:
- read .pact/state.md
- read the nearest AGENTS.md if working inside a module with local instructions
- run or apply the equivalent of: bash .pact/bin/pact.sh guard verify
- read .pact/contracts/[current-feature].md

For each FC entry:
- construct boundary inputs
- run real commands or tests
- capture real output

Write:
- .pact/knowledge/[current-feature]-verify.md

The verify file must contain exactly one:
- verdict = PASS
- verdict = FAIL
- verdict = INCONCLUSIVE

For PASS, include runtime evidence with command/output/result markers.
Do not use speculative language as evidence.
```

---

## Ship

```text
Ship the current PACT feature.

Before shipping:
- read .pact/state.md
- read the nearest AGENTS.md if working inside a module with local instructions
- run or apply the equivalent of: bash .pact/bin/pact.sh guard ship
- read .pact/knowledge/[current-feature]-verify.md
- confirm it contains verdict = PASS or MANUAL OVERRIDE

Run relevant tests.
Ask for manual acceptance if any contract items are not automated.

Then:
- move .pact/contracts/[current-feature].md to .pact/contracts/archive/[current-feature].md
- update .pact/state.md completed table
- clear current feature or move to the next queued feature

Do not ship if verify is FAIL or INCONCLUSIVE without documented manual override.
```

---

## Retro

```text
Run a PACT retro over the last 3-5 shipped features.

Read:
- nearest module-level AGENTS.md files if they exist for affected modules
- .pact/specs/PAD.md
- .pact/scope/fitness.md
- .pact/knowledge/tech-debt.md
- .pact/contracts/archive/

Assess:
- product intent drift
- PID clarity
- contract quality
- verification quality
- active technical debt
- whether /pact.scope should be rerun

Write:
- .pact/knowledge/decisions/[YYYY-MM-DD]-retro.md
```
