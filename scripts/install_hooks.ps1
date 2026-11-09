# Sets up Git to use repository-managed hooks in .githooks (PowerShell)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path "$PSScriptRoot\.."

Write-Host "Configuring git hooks path to .githooks..." -ForegroundColor Cyan
Set-Location $repoRoot
git config core.hooksPath .githooks

Write-Host "✅ Git hooks configured successfully!" -ForegroundColor Green
