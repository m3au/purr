#!/bin/sh

set -euo pipefail

echo "Removing build artifacts and development dependencies..."

# Remove build directories and clean ignored files
./scripts/clean.sh

# Clean test environment if it exists
if [ -d "tests/root" ]; then
    chmod -R 755 "tests/root" 2>/dev/null || true
    rm -rf "tests/root"
fi

# Development dependencies to remove
dev_packages=(
    shellcheck
    shfmt
    shellspec
    go-md2man
)

# Remove dev tools if installed via brew
if command -v brew >/dev/null; then
    for pkg in "${dev_packages[@]}"; do
        if brew list --formula | grep -q "^${pkg}$"; then
            echo "Uninstalling ${pkg}..."
            brew uninstall "${pkg}" || true
        fi
    done
fi

echo "✓ Removed development dependencies"
