# Using PACT

PACT is a protocol layer for AI-assisted software development. It does not replace your editor, agent, tests, git workflow, deployment pipeline, or product judgment.

Use it to keep feature work explicit:

```text
intent -> contract -> build -> verify -> ship
```

For Chinese, see [USAGE.zh.md](./USAGE.zh.md).

---

## 1. Choose Your Adapter

PACT is tool-agnostic at the protocol layer, but different AI tools load project instructions differently.

| Tool | Recommended adapter | Support level |
|------|---------------------|---------------|
| Claude Code | `.claude/commands/*.md` slash commands | First-class |
| Codex | `AGENTS.md` + `.pact/` scripts and templates | Compatible |
| Cursor | `.cursor/rules/pact.mdc` + `.pact/` scripts and templates | Compatible |

Details:
- [Claude Code adapter](./docs/adapters/claude-code.md)
- [Codex adapter](./docs/adapters/codex.md)
- [Cursor adapter](./docs/adapters/cursor.md)

---

## 2. Install Into a Project

Detailed installation options: [INSTALL.md](./INSTALL.md)

Recommended remote installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.ps1 | iex"
```

This directly installs PACT files into the target project.

If you are working from the PACT source repository, you can also run the copy command from the repository root:

```bash
cp -r CLAUDE.md .claude .pact AGENTS.md .cursor your-project/
```

Or use the installer:

```bash
bash scripts/install-pact.sh --target your-project --mode auto
```

On Windows PowerShell:

```powershell
.\scripts\install-pact.ps1 -Target your-project -Mode auto
```

If you are copying from a parent directory that contains the cloned `pact/` folder, prefix the source paths:

```bash
cp -r pact/CLAUDE.md pact/.claude pact/.pact pact/AGENTS.md pact/.cursor your-project/
```

Choose the file set that matches your tool.

### Minimum Portable Set

```text
.pact/
AGENTS.md
```

### Claude Code First-Class Set

```text
CLAUDE.md
.claude/commands/
.pact/
```

### Codex Set

```text
AGENTS.md
.pact/
```

### Cursor Set

```text
.cursor/rules/pact.mdc
.pact/
AGENTS.md
```

`AGENTS.md` is the portable agent entry. `CLAUDE.md` is Claude Code-specific. For modules with strong local conventions, create a module-level `AGENTS.md` from `.pact/templates/module-AGENTS.md`.

---

## 3. Initialize the Project

In Claude Code:

```text
/pact.init
/pact.scope
```

In Codex or Cursor, ask the agent to perform the same PACT stages:

```text
Initialize this project using PACT. Create or update constitution, PAD, and state.
Then run the PACT scope assessment before the first feature.
```

What happens:
- `/pact.init` creates project-level facts: constitution, PAD draft, and state.
- `/pact.scope` assesses whether PACT is appropriate and identifies risk boundaries.
- Scope is strongly recommended before the first feature, but it is not a state-machine phase.

---

## 4. Develop One Feature

Run one feature through the main flow:

```text
/pact.pid
/pact.contract
/pact.build
/pact.verify
/pact.ship
```

If your tool does not support slash commands, use natural-language equivalents:

```text
Create the PACT PID Card for [feature].
Generate the behavior contract from the PID Card.
Build against the contract.
Verify the feature with real command output.
Ship and archive the feature after PASS.
```

Expected artifacts:

| Stage | Output |
|-------|--------|
| `pid` | `.pact/specs/[feature]-pid.md` |
| `contract` | `.pact/contracts/[feature].md` |
| `build` | Code changes + `state.md` moves to `build-complete` |
| `verify` | `.pact/knowledge/[feature]-verify.md` |
| `ship` | Archived contract + updated state |

---

## 5. When PACT Stops

PACT should stop instead of guessing when:

- a high-risk boundary is detected
- a required PID Card, contract, or verify record is missing
- contract lint or verify lint fails
- verify is `FAIL` or `INCONCLUSIVE`
- manual acceptance is required
- a large feature needs an execution plan

Use the stop as a decision point. Do not treat it as an error to bypass.

---

## 6. Maintain the Project

Every 3-5 shipped features, run:

```text
/pact.retro
```

For Codex or Cursor:

```text
Run a PACT retro over the last 3-5 shipped features.
Check intent drift, contract quality, verification quality, and active technical debt.
```

Before publishing or sharing framework changes:

```bash
bash .pact/bin/pact-check.sh
```

Inside an installed project:

```bash
bash .pact/bin/pact.sh check --project
```

To check agent entry files:

```bash
bash .pact/bin/pact.sh lint-agents --all
```

If the project adopts PACT's release layer with `VERSION` and `CHANGELOG.md`:

```bash
bash .pact/bin/pact-release-check.sh
```

---

## 7. Release Discipline

PACT does not require a version bump for every documentation or rule edit.

Use releases only when the change set has clear release value:
- `PATCH`: refinements to existing behavior, docs, templates, or checks
- `MINOR`: a complete new capability
- `MAJOR`: incompatible protocol or state-machine changes

Release notes come from `CHANGELOG.md`.

---

## 8. Further References

- For Codex, Cursor, or other tools without slash commands, use [prompt templates](./docs/adapters/prompts.md).
- For runnable sample flows, see [examples](./examples/).
- For the core workflow reference, see [.pact/core/workflow.md](./.pact/core/workflow.md).
