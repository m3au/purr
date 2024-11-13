#!/bin/sh

set -e

# Check if shellspec is installed
if ! command -v shellspec >/dev/null; then
  echo "Error: shellspec is required but not installed"
  echo "Run 'make setup' to install dependencies"
  exit 1
fi

shellspec --format documentation --require spec_helper.sh --shell /bin/sh -- "./*_spec.sh"
