# Changelog

All notable changes to PACT are documented here.

PACT follows semantic versioning: `MAJOR.MINOR.PATCH`.

This changelog follows a Keep a Changelog style:
- newest releases first
- each release uses `## vX.Y.Z — YYYY-MM-DD`
- changes are grouped under `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`
- empty groups are omitted
- entries describe user- or maintainer-visible changes, not raw commit history

---

## v1.10.0 — 2026-05-06

### Added
- Added feature sizing rules to keep each feature within one `contract -> build -> verify -> ship` loop.
- Added oversized contract linting for contracts with more than 7 FC entries, including fixture coverage.
- Added `.pact/knowledge/patterns.md` for durable cross-feature engineering patterns.
- Added reusable pattern candidate fields to verify and handover templates.
- Added draft structured queue schema and examples: `.pact/schemas/queue.schema.json`, `.pact/queue.example.json`, and `.pact/state.example.json`.

### Changed
- `/pact.build`, `/pact.ship`, and `/pact.retro` now route reusable discoveries through the patterns knowledge layer.
- Documented feature sizing, reusable patterns, and draft structured state / queue files in README and usage docs.
- Clarified that the release layer is optional for projects that adopt `VERSION` and `CHANGELOG.md`.
- Repository self-check now requires the structured state / queue draft files and patterns knowledge file.

## v1.9.0 — 2026-05-05

### Added
- Added `.pact/bin/pact-state.sh` with controlled state operations: `validate`, `enqueue`, `set-phase`, `complete`, and `fail-verify`.
- Added `state` to the unified `.pact/bin/pact.sh` wrapper.
- Added logical state consistency checks for current / queue / completed conflicts, duplicate queue and completed entries, unsafe feature names, and phase-to-artifact consistency.
- Added verify failure recovery that records failure notes under `.pact/knowledge/errors/` and returns the active feature to `build`.
- Added `check --stale` diagnostics for long-running active work, repeated verify failures, and empty queue anomalies.
- Added state command fixtures and invalid-state fixtures for the new consistency checks.

### Changed
- `pact-check.sh` now calls the controlled state validator as part of project and repository self-check.
- Documented `pact state` as the recommended v1.x state mutation entry while keeping `.pact/state.md` as the source of truth.

---

## v1.8.0 — 2026-04-30

### Added
- Added `.pact/bin/pact-lint-agents.sh` for checking AGENTS entry file quality.
- Added `lint-agents` to the unified `.pact/bin/pact.sh` wrapper and repository self-check.
- Added AGENTS lint fixtures covering valid entries, overlong files, missing workflow references, excessive references, and warning-only instruction files.
- Added `.pact/templates/module-AGENTS.md` for module-level agent instruction files.

### Changed
- Updated `AGENTS.md` with a phase decision table, Don't / Do guidance, and explicit portable-entry responsibilities.
- Clarified that `CLAUDE.md` is the Claude Code runtime entry while `AGENTS.md` remains the portable cross-tool agent entry.
- Updated Cursor rules, adapter docs, prompt templates, README, and usage docs to describe agent entry quality and module-level AGENTS files.
- Documented agent entry lint rules in the workflow and constitution references.

---

## v1.7.1 — 2026-04-28

### Added
- Added `examples/secure-notes`, a more realistic completed PACT flow covering note ownership, denied cross-user access, validation, storage failure, and verification evidence.
- Added `examples/README.md` as an index for runnable examples.

### Changed
- Updated README and usage docs to point to the examples index and canonical workflow reference.
- Reduced workflow and prompt duplication in Codex and Cursor adapter docs by pointing to the canonical workflow reference and maintained prompt templates.

### Fixed
- Clarified Windows PowerShell self-check instructions after installation to avoid passing Windows absolute paths directly to Bash.
- Added installer output notes for Windows path handling.

---

## v1.7.0 — 2026-04-28

### Added
- Added GitHub remote installers for direct project installation from repository archives.
- Added `auto` mode support to shell and PowerShell source installers.
- Added unified installer scripts for source-based installation, including shell and PowerShell variants.
- Added Codex and Cursor adapter files and expanded adapter documentation for Claude Code, Codex, and Cursor.
- Added reusable non-Claude prompt templates for tools that do not support Claude Code slash commands.
- Added a runnable `examples/todo-feature` sample showing PID, archived contract, verification evidence, shipped state, and tests.
- Added the `.pact/bin/pact.sh` unified command wrapper for project and repository checks.

### Changed
- Changed the primary installation path to GitHub remote installers that write PACT files directly into the target project.
- Updated installed-project self-check guidance to use the unified project check entry.
- Clarified tool support boundaries for Claude Code, Codex, and Cursor.
- Strengthened first-use guidance so new users can install, inspect, and verify PACT with fewer manual steps.
- Aligned `AGENTS.md`, Cursor rules, adapter docs, and usage docs around the same installed-project workflow.

### Removed
- Removed the package source tree from the main branch.
- Removed package publishing workflows from the main branch.
- Yanked the withdrawn package artifact and removed it from the maintained installation path.

---

## v1.6.1 — 2026-04-27

### Changed
- Narrowed `/pact.scope` to PACT applicability and risk-boundary assessment.
- Replaced high/medium/low scope scoring with usage modes: `PACT-only`, `PACT + specialist review`, and `Do not use PACT alone`.
- Made FDG generation an optional planning artifact instead of a core scope output.
- Updated `fitness.md`, FDG template notes, README, and CLAUDE command descriptions to reflect the narrowed scope role.
- Clarified release cadence rules: accumulate small changes locally or in normal commits, and publish only when the change set has clear release value.

---

## v1.6.0 — 2026-04-27

### Added
- Added `.pact/bin/pact-guard.sh` for side-effect-free command entry checks.
- Added guard support for `pid`, `contract`, `build`, `verify`, and `ship`.
- Added guard fixture tests through `pact-guard.sh --fixtures`.

### Changed
- `pact-check.sh` now runs guard fixture checks.
- README and constitution now document Command Guard rules.

---

## v1.5.0 — 2026-04-27

### Added
- Added `.pact/bin/pact-lint-contract.sh` for behavior contract structure checks.
- Added `.pact/bin/pact-lint-verify.sh` for verification record structure checks.
- Added contract lint fixtures for valid contract, missing FC, missing out-of-scope, and template placeholder cases.
- Added verify lint fixtures for valid PASS, missing verdict, duplicate verdict, speculative language, and PASS without runtime evidence cases.

### Changed
- `pact-check.sh` now runs contract and verify lint fixtures.
- `pact-check.sh` now lints active and archived contract files when present.
- `pact-check.sh` now lints verify records when present.
- README and constitution now document Contract / Verify lint rules.

---

## v1.4.0 — 2026-04-27

### Added
- Added `VERSION` as the single editable version source.
- Added `RELEASE.md` with file-only, git-aware, and GitHub-aware release layers.
- Added optional `.pact/bin/pact-release-check.sh` for local git-based release readiness checks.

### Changed
- `pact-check.sh` now reads version from `VERSION` and remains file-only.
- Release rules now distinguish PACT internal checks from optional repository publishing workflows.
- README / README.zh link to `RELEASE.md` for release process details.

---

## v1.3.3 — 2026-04-27

### Added
- Added this `CHANGELOG.md` as the canonical local release history.

### Changed
- Release checks now require the current version to appear in `CHANGELOG.md`.
- README version history remains a compact summary and points to this changelog for details.
- Open-source release rules now require changelog updates before publishing.

---

## v1.3.2 — 2026-04-27

### Added
- Added draft future state schema at `.pact/schemas/state.schema.json`.
- Added state fixtures for idle state, missing PID Card, missing contract, missing verify file, missing PASS verdict, and invalid phase.
- Added state structure lint to `.pact/bin/pact-check.sh`.
- Added fixture-based `check-state.sh` coverage to the repository self-check.

### Changed
- `check-state.sh` now supports `PACT_ROOT` and `PACT_STATE_FILE` for fixture testing.
- `build` phase now requires the active contract file, matching interrupted build behavior.
- README and constitution document the v1 state source and future v2 structured-state candidate.

---

## v1.2.1 — 2026-04-26

### Changed
- Refined README positioning around PACT as a lightweight protocol framework for auditable human-AI software development.
- Added GitHub Actions status badges to English and Chinese READMEs.
- Added guidance on when to use or avoid PACT.
- Documented the optional repository self-check command in Quick Start.

---

## v1.2.0 — 2026-04-26

### Added
- Added repository self-check script at `.pact/bin/pact-check.sh`.
- Added GitHub Actions workflow for PACT self-checks.
- Added version consistency checks across `README.md`, `README.zh.md`, and `CLAUDE.md`.
- Added guard against accidentally publishing internal roadmap drafts.
- Added open-source maintenance and release rules in `CLAUDE.md` and `constitution.md`.

---

## v1.1.0 — 2026-04-20

### Added
- Added start time to `state.md`.
- Extended completed-feature tables with start and completed date columns.

### Changed
- Hardened `check-state.sh` parsing with colon normalization and Markdown bold-marker handling.
- Replaced brittle `grep + sed` chains with `awk` parsing.
- Added README scope section and English README.

---

## v1.0.0 — 2026-04-20

### Added
- Initial public release of PACT.
- Added 8 command protocols.
- Added 3-layer context loading model.
- Added risk boundary detection.
- Added adversarial verification flow.
- Added shell-hook safety net.
