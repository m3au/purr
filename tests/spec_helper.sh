#!/usr/bin/env bash

# Set up test environment
setup_test_env() {
  # Create temporary test directories
  TEST_HOME=$(mktemp -d)
  export HOME="$TEST_HOME"
  export XDG_CONFIG_HOME="$TEST_HOME/.config"
  export XDG_DATA_HOME="$TEST_HOME/.local/share"
  export XDG_CACHE_HOME="$TEST_HOME/.cache"
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
  mkdir -p "$TEST_HOME/.local/share/zsh/site-functions"
  chmod -R 755 "$TEST_HOME"
  touch "$HOME/.zshrc"

  # Store current directory
  ORIG_PWD="$PWD"

  # Create required files and directories
  mkdir -p src/lib src/bin src/completion
  touch src/lib/common.sh
  chmod +x src/lib/common.sh
  echo "0.0.0" > VERSION
  touch LICENSE README.md
  mkdir -p docs
  touch docs/purr.1.md

  # Clean any existing test artifacts
  rm -rf "tests/dev"
  rm -rf "dist"

  # Create test directories
  mkdir -p "tests/dev/dist"
  mkdir -p "tests/dev/coverage"
  mkdir -p "dist"

  # Create script directories
  mkdir -p scripts
  chmod +x scripts/*

  # Ensure VERSION exists with initial value
  echo "0.0.0" > VERSION

  # Create required directories
  mkdir -p dist/{man,completion}
  mkdir -p tests/dev/dist/{man,completion}
  mkdir -p docs

  # Create required files
  touch docs/purr.1.md
  touch LICENSE README.md

  # Create source structure
  mkdir -p src/{bin,lib,completion}
  touch src/lib/common.sh
  chmod +x src/lib/common.sh
}

# Restore original environment
cleanup_test_env() {
  cd "$ORIG_PWD" || exit 1
  if [ -d "$TEST_HOME" ]; then
    chmod -R 755 "$TEST_HOME" 2>/dev/null || true
    rm -rf "$TEST_HOME"
  fi
  unset HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME SHELL QUIET PURR_TEST PURR_ROOT PURR_LIB PURR_BIN ORIG_PWD
}

# Helper functions for tests
assert_file_exists() {
  [ -f "$1" ]
}

assert_dir_exists() {
  [ -d "$1" ]
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  grep -q "$pattern" "$file"
}

assert_file_mode() {
  local file="$1"
  local mode="$2"
  [ "$(stat -f %p "$file")" = "$mode" ]
}

verify_archive_contents() {
  local archive="$1"
  local prefix="$2"
  local tmp_dir="$TEST_HOME/extract"

  mkdir -p "$tmp_dir"
  cp "$archive" "$tmp_dir/"
  cd "$tmp_dir" || return 1
  tar xzf "$(basename "$archive")"

  [ -d "$prefix" ] || return 1
  [ -d "$prefix/src" ] || return 1
  [ -f "$prefix/LICENSE" ] || return 1
  [ -f "$prefix/README.md" ] || return 1
  [ -f "$prefix/VERSION" ] || return 1
  [ -f "$prefix/install" ] || return 1
}
