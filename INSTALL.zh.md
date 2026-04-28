# 安装 PACT

PACT 会把框架文件安装到目标项目目录。

## 最新 main

Bash / Git Bash / WSL：

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell，安装到当前目录：

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.ps1 | iex"
```

Windows PowerShell，指定目标目录：

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/pact/main/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target your-project -Mode auto -Ref main
Remove-Item $installer
```

## 固定版本

Bash / Git Bash / WSL：

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/pact/v1.7.0/scripts/install-from-github.sh | bash -s -- --target . --mode auto --ref v1.7.0
```

Windows PowerShell：

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/pact/v1.7.0/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target . -Mode auto -Ref v1.7.0
Remove-Item $installer
```

## 模式

| 模式 | 安装内容 |
|------|----------|
| `auto` | 根据已有项目文件选择模式；没有明显信号时默认 `all` |
| `all` | `CLAUDE.md`、`.claude/`、`.pact/`、`AGENTS.md`、`.cursor/` |
| `claude` | `CLAUDE.md`、`.claude/`、`.pact/` |
| `codex` | `AGENTS.md`、`.pact/` |
| `cursor` | `.cursor/`、`AGENTS.md`、`.pact/` |

## 自检

安装后，在目标项目根目录执行：

```bash
bash .pact/bin/pact.sh check --project
```

