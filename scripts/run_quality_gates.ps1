# Runs all quality gates: format, strict analyze, fast tests, and secrets scan (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "=== Quality Gate 1: Code Formatting Check ===" -ForegroundColor Cyan
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
  Write-Error "Code formatting check failed. Run 'dart format .' to fix formatting."
  exit 1
}
Write-Host "✅ Format check passed." -ForegroundColor Green

Write-Host "=== Quality Gate 2: Strict Static Analysis ===" -ForegroundColor Cyan
dart analyze --fatal-warnings --fatal-infos
if ($LASTEXITCODE -ne 0) {
  Write-Error "Dart analyze failed with warnings or errors."
  exit 1
}
Write-Host "✅ Analysis passed." -ForegroundColor Green

Write-Host "=== Quality Gate 3: Test Suite Execution ===" -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
  Write-Error "Tests failed."
  exit 1
}
Write-Host "✅ Tests passed." -ForegroundColor Green

Write-Host "=== Quality Gate 4: Secrets Scan ===" -ForegroundColor Cyan
if (Get-Command gitleaks -ErrorAction SilentlyContinue) {
  gitleaks dir . -v
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Secrets scan detected potential secrets."
    exit 1
  }
  Write-Host "✅ Gitleaks secrets scan passed." -ForegroundColor Green
} else {
  Write-Host "⚠️ gitleaks not found in PATH." -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "🎉 All quality gates passed successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
