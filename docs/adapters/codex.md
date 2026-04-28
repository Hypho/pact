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
python -m pip install .
pact install --target your-project --mode codex
```

After PyPI publication, use `pip install pact-toolkit`.

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

Codex-compatible prompts:

```text
Initialize this project using PACT.
```

```text
Create the PACT PID Card for user login.
```

```text
Generate the PACT behavior contract from the current PID Card.
```

```text
Build the current feature against the PACT contract.
```

```text
Verify the current feature using real command output and write the PACT verify record.
```

```text
Ship the current PACT feature after PASS and archive the contract.
```

For a complete prompt set, see [prompts.md](./prompts.md).

## Checks

Run:

```bash
pact check --project
```

If the project adopts PACT's release layer with `VERSION` and `CHANGELOG.md`:

```bash
bash .pact/bin/pact-release-check.sh
```

## Limitations

Codex will not automatically expose `/pact.*` commands from `.claude/commands`. Treat those files as Claude Code-specific command definitions.
