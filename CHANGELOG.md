# Changelog

All notable changes to PACT are documented here.

PACT follows semantic versioning: `MAJOR.MINOR.PATCH`.

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
