#!/usr/bin/env bash
# Sets up Git to use repository-managed hooks in .githooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Configuring git hooks path to .githooks..."
cd "$REPO_ROOT"
git config core.hooksPath .githooks

chmod +x .githooks/pre-commit .githooks/commit-msg 2>/dev/null || true

echo "✅ Git hooks configured successfully!"
