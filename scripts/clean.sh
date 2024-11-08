#!/usr/bin/env bash

set -euo pipefail

echo "Cleaning build artifacts..."

# Remove build directories
rm -rf tests/root dist

# Clean ignored files
git clean -fXd

echo "✓ Cleaned development environment"
