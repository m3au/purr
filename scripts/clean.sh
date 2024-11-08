#!/bin/sh

set -eo pipefail

echo "Cleaning build artifacts..."

# Clean and recreate test environment
if [ -d "tests/root" ]; then
    chmod -R 755 "tests/root" 2>/dev/null || true
    rm -rf "tests/root"
fi

# Recreate test directory structure
mkdir -p "tests/root/.config/purr"
mkdir -p "tests/root/.local/share/purr"
mkdir -p "tests/root/.cache/purr"
mkdir -p "tests/dist"

# Clean up XDG cache directory
if [ -n "${XDG_CACHE_HOME-}" ]; then
    cache_dir="$XDG_CACHE_HOME/purr"
else
    cache_dir="$HOME/.cache/purr"
fi
if [ -d "$cache_dir" ]; then
    rm -rf "$cache_dir"
fi

# Remove any temporary test files
find . -type f -name "*_spec.tmp" -delete 2>/dev/null || true

# Clean up any leftover coverage data
rm -rf coverage .coverage coverage.info 2>/dev/null || true

echo "✓ Cleaned build artifacts"
