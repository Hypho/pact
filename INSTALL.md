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
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/v1.8.0/scripts/install-from-github.sh | bash -s -- --target . --mode auto --ref v1.8.0
```

Windows PowerShell:

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/pact/v1.8.0/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target . -Mode auto -Ref v1.8.0
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

On Windows PowerShell, run the check after changing into the target directory:

```powershell
Set-Location your-project
bash .pact/bin/pact.sh check --project
```

Do not pass a Windows absolute path such as `C:\path\project\.pact\bin\pact.sh` directly to `bash`; Git Bash and WSL parse those paths differently. Enter the project directory first, or use a POSIX path such as `/mnt/c/path/project` when running from WSL.
