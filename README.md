# PACT — Product-Aware Contract Toolkit
> A lightweight protocol framework for auditable human-AI software development | v1.6.1
> 中文: [README.zh.md](./README.zh.md)

[![PACT Check](https://github.com/Hypho/pact/actions/workflows/pact-check.yml/badge.svg)](https://github.com/Hypho/pact/actions/workflows/pact-check.yml)

---

## What is it

PACT is a lightweight protocol framework for building software with AI while keeping product intent, implementation scope, and verification evidence explicit.

It turns AI-assisted development from an open-ended chat into a staged workflow: define intent, write a behavior contract, implement against that contract, verify with real outputs, then archive what changed.

PACT is designed for product-minded builders, solo developers, and small teams who want AI to move faster without losing control of scope, state, and quality.

It is not a code generator, an agent scheduler, or a replacement for CI/CD. It is the protocol layer that keeps human decisions and AI execution aligned.

Core idea: **Define behavior before implementation. Verify behavior before shipping.**

---

## When to use PACT

Use PACT when:

- You are building a product with AI assistance and need the work to remain auditable.
- You want clear handoffs between product intent, implementation, verification, and release.
- You are a solo developer, product-minded builder, or small team working feature by feature.
- You prefer explicit contracts and checkpoints over relying on long prompts.

Avoid PACT when:

- You need a general-purpose task manager or multi-agent scheduler.
- You need deployment, monitoring, incident response, or CI/CD orchestration.
- You are solving high-risk security, financial, concurrency, or performance problems without specialist review.

---

## Scope

Before adopting, check whether your project falls within PACT's applicable scope.

### Detected but not solved (framework halts, expects external specialist input)

- **Transaction consistency and concurrency races** — boundaries B-H02 / B-H05
- **Financial operations and sensitive data** — boundaries B-H03 / B-H06
- **Cross-user aggregation / real-time communication** — boundaries B-H01 / B-H04
- **Code performance (N+1, slow queries, etc.)** — runtime boundary scan in `/pact.build`

> PACT will actively stop you in these situations but does not propose solutions. Pair with specialized reviews (security / performance / DBA).
> The detect-and-halt behavior is itself one of the framework's deliverables.

### Entirely outside framework scope

- **Production deployment, monitoring, alerting**
- **Multi-developer concurrent development conflicts**
- **CI/CD pipelines and release management**

> PACT does not engage with these — use other toolchains.

---

## Quick Start

Full usage guide: [USAGE.md](./USAGE.md)

```bash
# Recommended universal installer from this repository
python -m pip install .
pact install --target your-project --mode all

# After PyPI publication, use:
# pip install pact-toolkit

# From the PACT repository root, copy the framework into your project root
cp -r CLAUDE.md .claude .pact AGENTS.md .cursor your-project/

# Or use the installer
bash scripts/install-pact.sh --target your-project --mode all

# In Claude Code, run:
/pact.init    # Project initialization (one-time)
/pact.scope   # Scope and risk-boundary assessment (recommended before first feature)

# Optional installed-project self-check
pact check --project --cwd your-project

# Framework maintainers: see RELEASE.md for release checks
```

The Python installer copies the framework files directly. Commands such as `pact check`, `pact guard`, and `pact lint-*` wrap PACT shell scripts and require `bash` at runtime.

---

## Tool Support

PACT is tool-agnostic at the protocol layer, with first-class Claude Code support and adapter files for Codex and Cursor.

| Tool | Support | Entry point |
|------|---------|-------------|
| Claude Code | First-class | [docs/adapters/claude-code.md](./docs/adapters/claude-code.md) |
| Codex | Compatible | [docs/adapters/codex.md](./docs/adapters/codex.md) |
| Cursor | Compatible | [docs/adapters/cursor.md](./docs/adapters/cursor.md) |

For non-Claude tools, use [docs/adapters/prompts.md](./docs/adapters/prompts.md).

Claude Code plugin marketplace installation is planned, not the current primary installation path.

---

## Example

See [examples/todo-feature](./examples/todo-feature/) for a runnable completed feature flow with PID, archived contract, verify record, shipped state, and a small test.

---

## Execution Model

Per-feature flow: `pid → contract → build → verify → ship`

Every 3–5 features: `retro`

---

## Commands

| Command | When | Responsibility |
|---------|------|----------------|
| `/pact.init` | Project start (one-time) | Interactive init; generates constitution, PAD draft, state |
| `/pact.scope` | Recommended before first feature; re-run when risk boundaries or product direction change | PACT applicability and risk-boundary assessment; FDG is optional |
| `/pact.pid` | Each feature start | Define feature intent, run boundary detection, generate PID Card |
| `/pact.contract` | After pid | Generate behavior contract (FC/NF entries) as the baseline for build and verify |
| `/pact.build` | After contract | TDD implementation (tests first, then code) |
| `/pact.verify` | After build | Adversarial verification: construct edge inputs, issue verdict based on real runtime output |
| `/pact.ship` | After verify PASS | Smoke tests, record completion, archive contract |
| `/pact.retro` | Every 3–5 features | Review contract quality, clean up technical debt |

---

## Directory Structure

```
your-project/
├── CLAUDE.md                        ← Hot layer, auto-loaded at session start
│                                      Contains: startup sequence / execution model / commands / file assembly rules
├── .claude/
│   └── commands/                    ← 8 command files (per-command protocols)
│       ├── pact.init.md
│       ├── pact.scope.md
│       ├── pact.pid.md
│       ├── pact.contract.md
│       ├── pact.build.md
│       ├── pact.ship.md
│       ├── pact.verify.md
│       └── pact.retro.md
└── .pact/
    ├── state.md                     ← Hot layer, cross-session state machine
    ├── core/
    │   ├── constitution.md          ← Warm layer: project charter, hard constraints + file-naming rules
    │   └── architecture.md          ← Cold layer: load on demand
    ├── schemas/
    │   └── state.schema.json        ← Draft structured state schema for future migration
    ├── scope/
    │   ├── boundaries.md            ← Boundary checklist (B-H / B-M risk rules)
    │   └── fitness.md               ← Adaptation assessment output (/pact.scope)
    ├── specs/                       ← Project instances (generated by commands, not blank templates)
    │   ├── PAD.md                   ← Product Architecture Document (/pact.init draft)
    │   ├── FDG.md                   ← Optional Feature Dependency Graph (/pact.scope, explicit opt-in)
    │   └── [feature]-pid.md         ← Per-feature PID Cards (/pact.pid)
    ├── contracts/                   ← Behavior contracts
    │   ├── [feature].md             ← Active feature contract
    │   └── archive/                 ← Completed contracts (/pact.ship)
    ├── templates/                   ← Blank reference templates (never filled directly)
    │   ├── PAD.md / FDG.md / IFD.md
    │   ├── pid-card.md / contract.md / verify.md
    │   ├── exec-plan.md / handover.md
    │   └── README.md
    ├── hooks/
    │   └── check-state.sh           ← SessionStart hook (validates state.md vs filesystem)
    ├── exec-plans/
    │   ├── active/                  ← Active large-feature plans
    │   └── completed/
    ├── knowledge/
    │   ├── [feature]-verify.md      ← Verify record (verdict + adversarial test results)
    │   ├── tech-debt.md             ← Technical debt tracking
    │   ├── decisions/               ← Architecture decision archive
    │   ├── errors/                  ← Failure records
    │   ├── handover/
    │   └── archive/                 ← Historical state / completed feature archive
    └── tests/
        ├── features/
        ├── fixtures/
        └── api/
```

---

## Key Mechanisms

### File Naming Convention
All contract / verify / exec-plan / pid-card paths are derived from the feature-name field in state.md, following rules defined in constitution.md. The startup check compares the phase declared in state.md against the corresponding files; mismatch halts execution.

### State Source
In v1.x, `.pact/state.md` remains the human-readable source of truth. PACT also includes a draft `.pact/schemas/state.schema.json` to define the future structured state shape, but it does not change the current runtime behavior.

`pact-check.sh` now validates the basic `state.md` structure and runs fixture checks for common invalid states before release.

### Contract / Verify Lint
PACT checks that behavior contracts and verification records are structurally valid:

- contracts must include FC entries and explicit out-of-scope boundaries
- contracts must not contain obvious template placeholders
- verify records must include exactly one strict `verdict = PASS|FAIL|INCONCLUSIVE` line
- verify records reject speculative language such as "should", "expected", and "theoretically"
- PASS verify records must include a runtime evidence marker such as `output:` or `command:`

### Command Guard
PACT includes a command guard that checks whether a `/pact.*` command is allowed to start based on `state.md` and required artifacts.

```bash
bash .pact/bin/pact-guard.sh pid
bash .pact/bin/pact-guard.sh contract
bash .pact/bin/pact-guard.sh build
bash .pact/bin/pact-guard.sh verify
bash .pact/bin/pact-guard.sh ship
```

The guard does not execute commands, generate files, or modify state. It only reports whether the command may start.

### Scope Assessment

`/pact.scope` checks whether PACT is appropriate for the project and identifies risk boundaries before feature work starts.

It outputs one of three usage modes:

- `PACT-only`
- `PACT + specialist review`
- `Do not use PACT alone`

FDG generation is optional. It should only be generated when the developer explicitly provides 3+ known features and wants dependency planning.

### Boundary Detection
`/pact.pid` scans the current feature against boundaries.md:

| Level | Scope | Response |
|-------|-------|----------|
| High risk (B-H) | Real-time comms / concurrent writes / financial ops / cross-user aggregation / multi-table transactions / sensitive data | Hard halt, wait for human decision |
| Mid risk (B-M) | Complex permissions / file handling / third-party integration / async tasks / complex queries / schema changes | Advisory note, may continue |

Large-feature gating (spans 3+ modules / schema changes / needs 2+ sessions / depends on 3+ unfinished features) → mandatory execution plan, requires human confirmation.

### Verify Mechanism
Not code review, but active falsification. For each FC entry, construct edge inputs, run them for real, capture real output; inferential language is prohibited. Three possible verdicts: `PASS` / `FAIL` (roll back to build) / `INCONCLUSIVE` (triaged via a three-option protocol).

---

## Versioning Rules

Semantic versioning: `MAJOR.MINOR.PATCH`

| Position | Trigger | Typical change |
|----------|---------|----------------|
| **MAJOR** | Breaking protocol change; initialized projects cannot upgrade smoothly | Commands added/removed/renamed; state-machine phase changes; file-naming rule changes; directory restructure |
| **MINOR** | Backward-compatible protocol extension | New optional Step or check; new template; new non-mandatory sub-protocol; hook capability enhancement |
| **PATCH** | No new standalone capability | Wording / typo fixes; internal consistency fixes; responsibility narrowing; template alignment; small adjustments to existing checks |

> Version numbers change only for release-worthy change sets. Small edits may accumulate in local work or normal commits before a release.
> Milestones get git tags (`v1.0.0`, `v1.1.0`, `v2.0.0`).
> Keep the last 10 entries in the table below; older entries move to `CHANGELOG.md`.

---

## Version History

Detailed release notes are maintained in [CHANGELOG.md](./CHANGELOG.md).
Release process details are documented in [RELEASE.md](./RELEASE.md).

| Version | Date | Core changes |
|---------|------|--------------|
| v1.6.1 | 2026-04-27 | Narrows `/pact.scope` to applicability and risk-boundary assessment; makes FDG optional; clarifies lower-frequency release rules |
| v1.6.0 | 2026-04-27 | Adds command guard for pid / contract / build / verify / ship entry checks and integrates guard fixtures into self-check |
| v1.5.0 | 2026-04-27 | Adds contract and verify lint scripts, fixtures, and self-check integration for behavior contract and verification record structure |
| v1.4.0 | 2026-04-27 | Adds VERSION as the file-only version source, documents layered release workflows, and adds optional git-aware release checks |
| v1.3.3 | 2026-04-27 | Adds CHANGELOG.md as canonical release history and requires changelog coverage in repository self-checks |
| v1.3.2 | 2026-04-27 | Adds draft state schema, state fixtures, stricter state.md lint, fixture-based check-state coverage, and build-phase state validation |
| v1.2.1 | 2026-04-26 | Refines README positioning, adds CI status badge, clarifies when to use or avoid PACT, and documents the repository self-check command |
| v1.2.0 | 2026-04-26 | Adds repository self-check script and GitHub Actions workflow for version consistency, internal-roadmap leakage prevention, and state consistency; adds open-source maintenance and release rules |
| v1.1.0 | 2026-04-20 | Time triples (state.md adds started_at; completed table extended with start/completed columns); check-state.sh parsing hardened (colon normalization, awk replaces grep+sed); README adds "Scope" section with English version |
| v1.0.0 | 2026-04-20 | First public release. Contract-driven framework for product-minded developers: 8 command protocols + 3-layer context loading + risk boundary detection + adversarial verification + shell-hook safety net |
