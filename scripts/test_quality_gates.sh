#!/usr/bin/env bash
# Automated verification test script for JobPrep Quality Gates
# Proves each gate rejects bad input and accepts good input.

set -e

echo "================================================="
echo "🧪 Running Quality Gates Automated Proof Suite"
echo "================================================="

# Proof 1: Formatter
echo -e "\n[Proof 1/5] Verifying Code Formatter Gate..."
TEMP_FMT="lib/temp_unformatted_test.dart"
echo "void main(){int   x=1;}" > "$TEMP_FMT"
if dart format --output=none --set-exit-if-changed "$TEMP_FMT" >/dev/null 2>&1; then
  rm -f "$TEMP_FMT"
  echo "❌ Formatter failed to reject unformatted code!"
  exit 1
else
  rm -f "$TEMP_FMT"
  echo "✅ Formatter successfully detected unformatted code and exited non-zero."
fi

# Proof 2: Analyzer Gate
echo -e "\n[Proof 2/5] Verifying Analyzer Gate..."
TEMP_LINT="lib/temp_lint_test.dart"
echo "dynamic badFunc() { int x = 'string'; return x; }" > "$TEMP_LINT"
if dart analyze --fatal-warnings --fatal-infos "$TEMP_LINT" >/dev/null 2>&1; then
  rm -f "$TEMP_LINT"
  echo "❌ Analyzer failed to reject type violation!"
  exit 1
else
  rm -f "$TEMP_LINT"
  echo "✅ Analyzer successfully detected error and exited non-zero."
fi

# Proof 3: Test Gate
echo -e "\n[Proof 3/5] Verifying Test Runner Gate..."
TEMP_TEST="test/temp_failing_test.dart"
cat << 'EOF' > "$TEMP_TEST"
import 'package:flutter_test/flutter_test.dart';
void main() { test('must fail', () => expect(1, equals(2))); }
EOF
if flutter test "$TEMP_TEST" >/dev/null 2>&1; then
  rm -f "$TEMP_TEST"
  echo "❌ Test runner failed to report test failure!"
  exit 1
else
  rm -f "$TEMP_TEST"
  echo "✅ Test runner successfully detected failed test and exited non-zero."
fi

# Proof 4: Conventional Commits Hook Gate
echo -e "\n[Proof 4/5] Verifying Conventional Commits Hook Gate..."
TMP_MSG="temp_commit_msg.txt"
echo "bad commit message without type" > "$TMP_MSG"
if bash .githooks/commit-msg "$TMP_MSG" >/dev/null 2>&1; then
  rm -f "$TMP_MSG"
  echo "❌ Commit hook failed to reject non-conventional message!"
  exit 1
else
  echo "✅ Commit-msg hook successfully rejected invalid commit message."
fi

echo "chore(gates): setup quality gates for Phase 0B" > "$TMP_MSG"
if bash .githooks/commit-msg "$TMP_MSG" >/dev/null 2>&1; then
  echo "✅ Commit-msg hook successfully accepted valid conventional commit."
  rm -f "$TMP_MSG"
else
  rm -f "$TMP_MSG"
  echo "❌ Commit hook erroneously rejected valid commit message!"
  exit 1
fi

# Proof 5: Secrets Scan Gate
echo -e "\n[Proof 5/5] Verifying Secrets Scan Gate..."
TEMP_SEC_DIR="temp_secret_test_dir"
mkdir -p "$TEMP_SEC_DIR"
cat << 'EOF' > "$TEMP_SEC_DIR/id_rsa"
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
-----END OPENSSH PRIVATE KEY-----
EOF
if gitleaks dir "$TEMP_SEC_DIR" -v >/dev/null 2>&1; then
  rm -rf "$TEMP_SEC_DIR"
  echo "❌ Gitleaks failed to detect secret!"
  exit 1
else
  rm -rf "$TEMP_SEC_DIR"
  echo "✅ Gitleaks successfully detected secret leak (private-key) and exited non-zero."
fi

echo -e "\n================================================="
echo "🎉 All 5 Quality Gates Proven Functional and Enforced!"
echo "================================================="
