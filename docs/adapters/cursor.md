# Cursor Adapter

Cursor does not use Claude Code slash commands or Claude plugins.

Use PACT through:

```text
.cursor/rules/pact.mdc
AGENTS.md
.pact/
```

The Cursor rule gives the agent persistent project instructions. `.pact/` contains the protocol files, templates, scripts, and state.

## Install

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

Cursor-compatible prompts:

```text
Use PACT to initialize this project.
```

```text
Use PACT to create the PID Card for [feature].
```

```text
Use PACT to generate the behavior contract.
```

```text
Use PACT to build and verify the current feature.
```

```text
Use PACT to ship the feature after PASS.
```

For a complete prompt set, see [prompts.md](./prompts.md).

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
