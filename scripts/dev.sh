#!/bin/sh

set -euo pipefail

# Setup test environment
setup_test_env() {
    # Use tests/root as our test home
    export HOME="$PWD/tests/root"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_CACHE_HOME="$HOME/.cache"
    export SHELL="/bin/zsh"
    export QUIET=0
    export PURR_TEST=1
    export PURR_ROOT="$PWD"
    export PURR_LIB="$PURR_ROOT/src/lib"
    export PURR_BIN="$PURR_ROOT/src/bin"

    # Create minimal environment
    mkdir -p "$XDG_CONFIG_HOME/purr"
    mkdir -p "$XDG_DATA_HOME/purr/backups"
    mkdir -p "$XDG_CACHE_HOME/purr"
    mkdir -p "$HOME/.local/share/zsh/site-functions"
    chmod -R 755 "$HOME"
    touch "$HOME/.zshrc"

    # Log test environment
    echo "Test environment:"
    echo "  HOME=$HOME"
    echo "  PURR_ROOT=$PURR_ROOT"
    echo "  PURR_LIB=$PURR_LIB"
    echo "  PURR_BIN=$PURR_BIN"
}

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
