#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot

$OpencodeFiles = 'flow.md', 'subflow.md', 'player.md', 'coach.md'
$ClaudeFiles = 'flow.md', 'player.md', 'coach.md'

function Usage {
    [Console]::Error.WriteLine("Usage: scripts/install.ps1 <opencode|claude|all> [--global|--local]")
    exit 1
}

if ($args.Count -lt 1) { Usage }
$tool = $args[0]
$target = if ($args.Count -ge 2) { $args[1] } else { '--global' }
if ($tool -notin 'opencode', 'claude', 'all') { Usage }
if ($target -notin '--global', '--local') { Usage }

function Install-One($src, $dest, $files) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    if ((Resolve-Path $src).Path -eq (Resolve-Path $dest).Path) {
        Write-Output "skip: $src == $dest"
        return
    }
    foreach ($f in $files) {
        Copy-Item -LiteralPath (Join-Path $src $f) -Destination (Join-Path $dest $f)
    }
    Write-Output "installed: $dest"
}

if ($tool -in 'opencode', 'all') {
    $dest = if ($target -eq '--global') { Join-Path $HOME '.config/opencode/agents' } else { './.opencode/agents' }
    Install-One (Join-Path $RepoRoot '.opencode/agents') $dest $OpencodeFiles
}

if ($tool -in 'claude', 'all') {
    $dest = if ($target -eq '--global') { Join-Path $HOME '.claude/agents' } else { './.claude/agents' }
    Install-One (Join-Path $RepoRoot '.claude/agents') $dest $ClaudeFiles
}
