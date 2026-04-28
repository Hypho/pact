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

## Unreleased

### Added
- Added GitHub remote installers for direct project installation from repository archives.
- Added `auto` mode support to shell and PowerShell source installers.

### Changed
- Changed the primary installation path from PyPI command wrappers to GitHub remote installers that write PACT files directly into the target project.
- Removed PyPI from the maintained installation path because `pip install` does not directly install framework files into a project directory.

### Removed
- Removed Python package source files from the main branch.
- Removed GitHub Actions workflows for Python package builds and PyPI publishing.

---

## v1.7.0 — 2026-04-28

### Added
- Published PACT as the `pact-toolkit` Python package on PyPI.
- Added Python packaging metadata for publishing PACT as `pact-toolkit`.
- Added the `pact` CLI as the primary pip-installed command entry.
- Added `pact install --target <path> --mode all|claude|codex|cursor|auto` for installing PACT into projects.
- Added `pact doctor` for local environment detection and install-mode guidance.
- Added `pact check`, `pact guard`, `pact lint-contract`, `pact lint-verify`, and `pact release-check` wrappers around existing PACT shell checks.
- Added `pact install --mode auto` to select an adapter mode from existing project files.
- Added packaged framework assets so pip installs can generate `.pact`, `.claude`, `.cursor`, `AGENTS.md`, and `CLAUDE.md` in target projects.
- Added GitHub Actions workflows for Python package build validation and PyPI Trusted Publishing.
- Added unified installer scripts for source-based installation, including shell and PowerShell variants.
- Added Codex and Cursor adapter files and expanded adapter documentation for Claude Code, Codex, and Cursor.
- Added reusable non-Claude prompt templates for tools that do not support Claude Code slash commands.
- Added a runnable `examples/todo-feature` sample showing PID, archived contract, verification evidence, shipped state, and tests.
- Added the `.pact/bin/pact.sh` unified command wrapper for project and repository checks.

### Changed
- Updated README and usage documentation to make `pip install pact-toolkit` the primary installation path after PyPI publication.
- Updated installed-project self-check guidance to use `pact check --project`.
- Documented that pip installs PACT files while runtime validation still requires `bash`.
- Clarified tool support boundaries for Claude Code, Codex, and Cursor.
- Strengthened first-use guidance so new users can install, inspect, and verify PACT with fewer manual steps.
- Aligned `AGENTS.md`, Cursor rules, adapter docs, and usage docs around the same installed-project workflow.
- Expanded release process documentation with PyPI-aware publishing through Trusted Publishing.
- Updated package metadata and license declaration for modern Python packaging behavior.

### Fixed
- Expanded the v1.7.0 release notes after publication to cover the full released change set from v1.6.1.

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
