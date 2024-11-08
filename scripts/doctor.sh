#!/bin/sh

set -euo pipefail

echo "Checking development environment..."

# Check development dependencies first
echo "- Development dependencies:"
for cmd in shellcheck shfmt kcov go-md2man shellspec; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $cmd installed"
    else
        echo "✗ $cmd not installed"
        echo "Run 'make dev-setup' to install missing dependencies"
    fi
done

# Source test environment setup only after checking dependencies
. ./tests/spec_helper.sh
setup_test_env

# Check directory structure
echo "- Directory structure:"
for dir in "tests/root/.config/purr" "tests/root/.local/share/purr" "tests/root/.cache/purr" "tests/dist"; do
    if [ ! -d "$dir" ]; then
        echo "✗ Missing directory: $dir"
        echo "Run 'make dev-setup' to create missing directories"
    else
        echo "✓ Found directory: $dir"
    fi
done

# Check file permissions
echo "- File permissions:"
if find tests -name "*_spec.sh" -type f -perm -u+x >/dev/null; then
    echo "✓ Test files are executable"
else
    echo "✗ Test files not executable"
fi

if [ -x "src/bin/purr" ]; then
    echo "✓ Binary files are executable"
else
    echo "✗ Binary files not executable"
fi

# Check environment variables
echo "- Environment variables:"
for var in PURR_ROOT PURR_LIB PURR_BIN; do
    if [ -n "${!var:-}" ]; then
        echo "✓ $var set to: ${!var}"
    else
        echo "✗ $var not set"
    fi
done
