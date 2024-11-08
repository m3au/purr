#!/usr/bin/env bash

set -euo pipefail

# Run normal clean first
./scripts/clean.sh

echo "Removing development dependencies..."

# Remove dev tools if installed via brew
for pkg in shellcheck shfmt shellspec go-md2man; do
    if command -v brew >/dev/null && brew list --formula | grep -q "^$pkg$"; then
        echo "Uninstalling $pkg..."
        brew uninstall "$pkg" || true
    fi
done

echo "✓ Removed development dependencies"
