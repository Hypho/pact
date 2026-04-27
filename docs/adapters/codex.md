# Codex Adapter

Codex does not use Claude Code slash commands or Claude plugins.

Use PACT through:

```text
AGENTS.md
.pact/
```

`AGENTS.md` tells Codex how to follow the PACT workflow. `.pact/` contains the state file, templates, scripts, and checks.

## Install

Copy these into your project root:

```text
AGENTS.md
.pact/
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

## Checks

Run:

```bash
bash .pact/bin/pact-check.sh
```

If the project uses git:

```bash
bash .pact/bin/pact-release-check.sh
```

## Limitations

Codex will not automatically expose `/pact.*` commands from `.claude/commands`. Treat those files as Claude Code-specific command definitions.

