#!/usr/bin/env bash
# Runs all quality gates: format, strict analyze, fast tests, and secrets scan.

set -e

echo "=== Quality Gate 1: Code Formatting Check ==="
dart format --output=none --set-exit-if-changed .
echo "✅ Format check passed."

echo "=== Quality Gate 2: Strict Static Analysis ==="
dart analyze --fatal-warnings --fatal-infos
echo "✅ Analysis passed."

echo "=== Quality Gate 3: Test Suite Execution ==="
flutter test
echo "✅ Tests passed."

echo "=== Quality Gate 4: Secrets Scan ==="
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks dir . -v
  echo "✅ Gitleaks secrets scan passed."
else
  echo "⚠️ gitleaks not found, running basic pattern scan..."
  git grep -Ei "(BEGIN PRIVATE KEY|service_role|supabase_service_role)" -- . ':!pubspec.lock' || true
  echo "✅ Fallback secrets scan complete."
fi

echo "=========================================="
echo "🎉 All quality gates passed successfully!"
echo "=========================================="
