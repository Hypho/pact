# Cursor Adapter

Cursor does not use Claude Code slash commands or Claude plugins.

Use PACT through:

```text
.cursor/rules/pact.mdc
AGENTS.md
.pact/
```

The Cursor rule gives the agent persistent project instructions. `.pact/` contains the protocol files, templates, scripts, and state.

`AGENTS.md` remains the portable agent entry for cross-tool compatibility. `.cursor/rules/pact.mdc` should summarize the same workflow for Cursor and defer to `.pact/core/workflow.md` for phase facts.

## Install

Recommended:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target your-project --mode cursor
```

Direct GitHub installation is the primary path because it writes PACT files into the target project.

From the PACT repository root, copy these into your project root:

```text
.cursor/rules/pact.mdc
AGENTS.md
.pact/
```

Example:

```bash
cp -r .cursor AGENTS.md .pact your-project/
```

## Use

Cursor should follow `.cursor/rules/pact.mdc` and the canonical workflow in `.pact/core/workflow.md`.

For the maintained prompt set, see [prompts.md](./prompts.md).

For modules with strong local conventions, create a local `AGENTS.md` from `.pact/templates/module-AGENTS.md`.

## Rule Scope

The rule file is stored at:

```text
.cursor/rules/pact.mdc
```

It should be version-controlled with the project.

## Checks

Run:

```bash
bash .pact/bin/pact.sh check --project
```

Cursor may not automatically run this check unless you ask it to.

Agent entry lint:

```bash
bash .pact/bin/pact.sh lint-agents --all
```
