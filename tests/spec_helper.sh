#!/usr/bin/env bash

# Set up test environment
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

    # Create test distribution directory
    mkdir -p tests/dist/{man,completion}

    # Create required files if they don't exist
    [ -f VERSION ] || echo "0.0.0" > VERSION
    [ -f LICENSE ] || touch LICENSE
    [ -f README.md ] || touch README.md
    [ -f docs/purr.1.md ] || touch docs/purr.1.md

    # Create source structure if it doesn't exist
    mkdir -p src/{bin,lib,completion}
    [ -f src/lib/common.sh ] || touch src/lib/common.sh
    chmod +x src/lib/common.sh
}

# Helper functions for tests
assert_file_exists() { [ -f "$1" ]; }
assert_dir_exists() { [ -d "$1" ]; }
assert_file_contains() { grep -q "$2" "$1"; }
assert_file_mode() { [ "$(stat -f %p "$1")" = "$2" ]; }

# For shellspec tests
if [ "${SHELLSPEC:-}" = "1" ]; then
    ORIG_PWD="$PWD"
    trap 'cd "$ORIG_PWD"' EXIT
fi
