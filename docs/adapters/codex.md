# Codex Adapter

Codex does not use Claude Code slash commands or Claude plugins.

Use PACT through:

```text
AGENTS.md
.pact/
```

`AGENTS.md` tells Codex how to follow the PACT workflow. `.pact/` contains the state file, templates, scripts, and checks.

## Install

Recommended:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target your-project --mode codex
```

Direct GitHub installation is the primary path because it writes PACT files into the target project.

From the PACT repository root, copy these into your project root:

```text
AGENTS.md
.pact/
```

Example:

```bash
cp -r AGENTS.md .pact your-project/
```

Optional but useful for documentation parity:

```text
USAGE.md
USAGE.zh.md
README.md
```

## Use

Codex does not read `.claude/commands` as slash commands. Use natural-language requests that map to the canonical workflow in `.pact/core/workflow.md`.

For the maintained prompt set, see [prompts.md](./prompts.md).

## Checks

Run:

```bash
bash .pact/bin/pact.sh check --project
```

If the project adopts PACT's release layer with `VERSION` and `CHANGELOG.md`:

```bash
bash .pact/bin/pact-release-check.sh
```

## Limitations

Codex will not automatically expose `/pact.*` commands from `.claude/commands`. Treat those files as Claude Code-specific command definitions.
