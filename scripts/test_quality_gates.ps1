# Automated verification test script for JobPrep Quality Gates (PowerShell)
# Proves each gate rejects bad input and accepts good input.

$ErrorActionPreference = "Continue"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🧪 Running Quality Gates Automated Proof Suite" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# -------------------------------------------------------------
# Proof 1: Formatter Gate
# -------------------------------------------------------------
Write-Host "`n[Proof 1/5] Verifying Code Formatter Gate..." -ForegroundColor Yellow
$tempFormatFile = "lib/temp_unformatted_test.dart"
Set-Content -Path $tempFormatFile -Value "void main(){int   x=1;}"
try {
  $null = dart format --output=none --set-exit-if-changed $tempFormatFile 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✅ Formatter successfully detected unformatted code and exited non-zero." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Formatter failed to reject unformatted code!" -ForegroundColor Red
    exit 1
  }
} finally {
  if (Test-Path $tempFormatFile) { Remove-Item $tempFormatFile -Force }
}

# -------------------------------------------------------------
# Proof 2: Analyzer Gate (Strict lints with warnings as errors)
# -------------------------------------------------------------
Write-Host "`n[Proof 2/5] Verifying Analyzer Gate (Strict lints)..." -ForegroundColor Yellow
$tempLintFile = "lib/temp_lint_test.dart"
Set-Content -Path $tempLintFile -Value "dynamic badFunc() { int x = 'string'; return x; }"
try {
  $null = dart analyze --fatal-warnings --fatal-infos $tempLintFile 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✅ Analyzer successfully detected type error / lint violation and exited non-zero." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Analyzer failed to reject lint violation!" -ForegroundColor Red
    exit 1
  }
} finally {
  if (Test-Path $tempLintFile) { Remove-Item $tempLintFile -Force }
}

# -------------------------------------------------------------
# Proof 3: Test Gate (Fast tests)
# -------------------------------------------------------------
Write-Host "`n[Proof 3/5] Verifying Test Suite Gate..." -ForegroundColor Yellow
$tempFailingTest = "test/temp_failing_test.dart"
Set-Content -Path $tempFailingTest -Value "import 'package:flutter_test/flutter_test.dart'; void main() { test('must fail', () => expect(1, equals(2))); }"
try {
  $null = flutter test $tempFailingTest 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✅ Test runner successfully detected failed assertion and exited non-zero." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Test runner failed to report failing test!" -ForegroundColor Red
    exit 1
  }
} finally {
  if (Test-Path $tempFailingTest) { Remove-Item $tempFailingTest -Force }
}

# -------------------------------------------------------------
# Proof 4: Conventional Commits Hook Gate
# -------------------------------------------------------------
Write-Host "`n[Proof 4/5] Verifying Conventional Commits Hook Gate..." -ForegroundColor Yellow
$tempMsgFile = "temp_commit_msg.txt"
$shExe = "C:\Program Files\Git\bin\sh.exe"
try {
  # Test invalid message
  Set-Content -Path $tempMsgFile -Value "bad commit message without type"
  $null = & $shExe ./.githooks/commit-msg temp_commit_msg.txt 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✅ Commit-msg hook successfully rejected non-conventional message ('bad commit message without type')." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Commit-msg hook failed to reject invalid commit message!" -ForegroundColor Red
    exit 1
  }

  # Test valid message
  Set-Content -Path $tempMsgFile -Value "chore(gates): setup quality gates for Phase 0B"
  $null = & $shExe ./.githooks/commit-msg temp_commit_msg.txt 2>&1
  if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Commit-msg hook successfully accepted valid conventional message." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Commit-msg hook erroneously rejected valid commit message!" -ForegroundColor Red
    exit 1
  }
} finally {
  if (Test-Path $tempMsgFile) { Remove-Item $tempMsgFile -Force }
}

# -------------------------------------------------------------
# Proof 5: Secrets Scan Gate (Gitleaks)
# -------------------------------------------------------------
Write-Host "`n[Proof 5/5] Verifying Secrets Scan Gate (Gitleaks)..." -ForegroundColor Yellow
$tempSecretDir = "temp_secret_test_dir"
New-Item -ItemType Directory -Path $tempSecretDir -Force | Out-Null
$fakeSecretFile = "$tempSecretDir/id_rsa"
$fakeKey = "-----BEGIN OPENSSH PRIVATE KEY-----`nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW`n-----END OPENSSH PRIVATE KEY-----"
Set-Content -Path $fakeSecretFile -Value $fakeKey
try {
  $null = gitleaks dir $tempSecretDir -v 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✅ Gitleaks successfully detected secret leak (private-key) and exited non-zero." -ForegroundColor Green
  } else {
    Write-Host "  ❌ Gitleaks failed to detect secret!" -ForegroundColor Red
    exit 1
  }
} finally {
  if (Test-Path $tempSecretDir) { Remove-Item $tempSecretDir -Recurse -Force }
}

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "🎉 All 5 Quality Gates Proven Functional and Enforced!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
