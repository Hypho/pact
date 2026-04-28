param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [ValidateSet("auto", "all", "claude", "codex", "cursor")]
  [string]$Mode = "auto",

  [switch]$Force
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$TargetPath = New-Item -ItemType Directory -Force -Path $Target
$TargetFullPath = (Resolve-Path $TargetPath.FullName).Path

function Get-PactInstallMode {
  $hasClaude = (Test-Path (Join-Path $TargetFullPath ".claude")) -or (Test-Path (Join-Path $TargetFullPath "CLAUDE.md"))
  $hasCodex = Test-Path (Join-Path $TargetFullPath "AGENTS.md")
  $hasCursor = Test-Path (Join-Path $TargetFullPath ".cursor")
  $matches = @($hasClaude, $hasCodex, $hasCursor) | Where-Object { $_ }

  if ($matches.Count -gt 1) { return "all" }
  if ($hasClaude) { return "claude" }
  if ($hasCursor) { return "cursor" }
  if ($hasCodex) { return "codex" }
  return "all"
}

$RequestedMode = $Mode
if ($Mode -eq "auto") {
  $Mode = Get-PactInstallMode
}

function Copy-PactItem {
  param(
    [string]$Source,
    [string]$Destination
  )

  $sourcePath = Join-Path $Root $Source
  $destinationPath = Join-Path $TargetFullPath $Destination

  if (-not (Test-Path $sourcePath)) {
    throw "Missing source: $Source"
  }

  if ((Test-Path $destinationPath) -and (-not $Force)) {
    throw "Refusing to overwrite existing path: $Destination. Use -Force to overwrite."
  }

  if (Test-Path $destinationPath) {
    Remove-Item -Recurse -Force -LiteralPath $destinationPath
  }

  $parent = Split-Path -Parent $destinationPath
  if ($parent -and (-not (Test-Path $parent))) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  Copy-Item -Recurse -Force -LiteralPath $sourcePath -Destination $destinationPath
}

switch ($Mode) {
  "all" {
    Copy-PactItem "CLAUDE.md" "CLAUDE.md"
    Copy-PactItem ".claude" ".claude"
    Copy-PactItem ".pact" ".pact"
    Copy-PactItem "AGENTS.md" "AGENTS.md"
    Copy-PactItem ".cursor" ".cursor"
  }
  "claude" {
    Copy-PactItem "CLAUDE.md" "CLAUDE.md"
    Copy-PactItem ".claude" ".claude"
    Copy-PactItem ".pact" ".pact"
  }
  "codex" {
    Copy-PactItem "AGENTS.md" "AGENTS.md"
    Copy-PactItem ".pact" ".pact"
  }
  "cursor" {
    Copy-PactItem ".cursor" ".cursor"
    Copy-PactItem "AGENTS.md" "AGENTS.md"
    Copy-PactItem ".pact" ".pact"
  }
}

Write-Host "PACT installed."
Write-Host ""
Write-Host "Target: $TargetFullPath"
Write-Host "Mode:   $Mode"
if ($RequestedMode -eq "auto") {
  Write-Host "Auto:   selected from existing project files"
}
Write-Host ""
Write-Host "Next:"
Write-Host "- Claude Code: run /pact.init, then /pact.scope before the first feature."
Write-Host "- Codex/Cursor: ask the agent to initialize the project using PACT."
Write-Host "- Self-check:"
Write-Host "    cd `"$TargetFullPath`""
Write-Host "    bash .pact/bin/pact.sh check --project"
Write-Host ""
Write-Host "Windows note:"
Write-Host "- Run the bash check after cd into the project directory."
Write-Host "- Do not pass a C:\...\.pact\bin\pact.sh path directly to bash."
