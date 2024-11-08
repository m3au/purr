#!/usr/bin/env bash

# Set up test environment
setup_test_env() {
  # Store original values
  _OLD_PATH=$PATH
  _OLD_HOME=$HOME
  _OLD_SHELL=$SHELL
  _OLD_XDG_DATA_HOME=$XDG_DATA_HOME
}

# Restore original environment
restore_test_env() {
  # Restore original values
  PATH=$_OLD_PATH
  HOME=$_OLD_HOME
  SHELL=$_OLD_SHELL
  XDG_DATA_HOME=$_OLD_XDG_DATA_HOME

  # Clean up temp vars
  unset _OLD_PATH _OLD_HOME _OLD_SHELL _OLD_XDG_DATA_HOME
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

# Set up test environment when helper is sourced
setup_test_env
