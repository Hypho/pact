# Claude Code Adapter

Claude Code is the first-class PACT runtime today.

PACT uses Claude Code project slash commands:

```text
.claude/commands/pact.init.md
.claude/commands/pact.scope.md
.claude/commands/pact.pid.md
.claude/commands/pact.contract.md
.claude/commands/pact.build.md
.claude/commands/pact.verify.md
.claude/commands/pact.ship.md
.claude/commands/pact.retro.md
```

## Install

Copy these into your project root:

```text
CLAUDE.md
.claude/commands/
.pact/
```

Then start Claude Code from the project root.

## Use

Run:

```text
/pact.init
/pact.scope
/pact.pid
/pact.contract
/pact.build
/pact.verify
/pact.ship
```

Run `/pact.retro` every 3-5 shipped features.

## Optional Guard Scripts

The command files instruct Claude Code to run:

```bash
bash .pact/bin/pact-guard.sh <pid|contract|build|verify|ship>
```

You can also run the guard manually when debugging state issues.

## Optional Session Hook

PACT includes:

```text
.pact/hooks/check-state.sh
```

This can be registered in `.claude/settings.json` as a SessionStart hook. It is optional. If not registered, it is still exercised by `pact-check.sh`.

## Future Plugin Distribution

Claude Code supports plugin marketplaces hosted from GitHub repositories. PACT may later provide a Claude Code plugin marketplace so users can install PACT with:

```text
/plugin marketplace add Hypho/pact
/plugin install pact@pact
```

That is planned, not the current primary installation path.

