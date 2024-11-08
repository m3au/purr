#!/bin/sh

set -euo pipefail

echo "Cleaning build artifacts..."

# Remove build directories
rm -rf dist tests/dist tests/dev

# Clean ignored files
git clean -fXd

# Remove coverage folder from root
rm -rf coverage

echo "✓ Cleaned build artifacts"
