#!/usr/bin/env bash

# Set up test environment
setup_test_env() {
    # Set up environment variables
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
