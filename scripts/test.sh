#!/bin/sh

set -euo pipefail

echo "Setting up test environment..."

# Source test environment setup
. ./tests/spec_helper.sh && setup_test_env

# Run tests
cd tests && SHELLSPEC_LOAD_PATH=. shellspec --shell /bin/bash --quiet **/*_spec.sh

echo "✓ Tests complete"
