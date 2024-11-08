#!/bin/sh

set -euo pipefail

# Source test environment setup
. tests/spec_helper.sh

case "${1:-}" in
    clean)
        ./scripts/clean.sh
        ;;
    *)
        setup_test_env
        if [ $# -gt 0 ]; then
            # Run command in test environment
            exec "$@"
        else
            # Run purr in test environment
            exec ./src/bin/purr
        fi
        ;;
esac
