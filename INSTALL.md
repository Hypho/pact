# Install PACT

PACT installs framework files into a target project directory.

## Latest Main

Bash / Git Bash / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell, current directory:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.ps1 | iex"
```

Windows PowerShell, explicit target:

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target your-project -Mode auto -Ref main
Remove-Item $installer
```

## Fixed Release

Bash / Git Bash / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/v1.7.0/scripts/install-from-github.sh | bash -s -- --target . --mode auto --ref v1.7.0
```

Windows PowerShell:

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/pact/v1.7.0/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target . -Mode auto -Ref v1.7.0
Remove-Item $installer
```

## Modes

| Mode | Installs |
|------|----------|
| `auto` | Selects a mode from existing project files; defaults to `all` |
| `all` | `CLAUDE.md`, `.claude/`, `.pact/`, `AGENTS.md`, `.cursor/` |
| `claude` | `CLAUDE.md`, `.claude/`, `.pact/` |
| `codex` | `AGENTS.md`, `.pact/` |
| `cursor` | `.cursor/`, `AGENTS.md`, `.pact/` |

## Self-Check

After installation, run from the target project root:

```bash
bash .pact/bin/pact.sh check --project
```

