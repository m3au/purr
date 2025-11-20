#!/usr/bin/env bats
# test_helper.bats - Common test setup and teardown functions

# Setup function runs before each test
setup() {
  # Create temporary directory for tests
  TEST_TMPDIR=$(mktemp -d)
  export TEST_TMPDIR

  # Backup original environment variables
  export ORIG_HOME="$HOME"
  export ORIG_SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
  export ORIG_PURR_VAULT_NAME="${PURR_VAULT_NAME:-}"
  export ORIG_PURR_GPG_ITEM="${PURR_GPG_ITEM:-}"
  export ORIG_PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-}"
  export ORIG_PURR_SSH_AUTH_SOCK="${PURR_SSH_AUTH_SOCK:-}"
  export ORIG_GITHUB_TOKEN="${GITHUB_TOKEN:-}"

  # Set test environment variables
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/.gnupg"
  mkdir -p "$HOME/.cursor"

  # Set test vault/item names
  export PURR_VAULT_NAME="test-vault"
  export PURR_GPG_ITEM="test-gpg"
  export PURR_GITHUB_ITEM="test-github"
  export PURR_SSH_AUTH_SOCK="$TEST_TMPDIR/ssh-agent.sock"

  # Source the purr.zsh script
  local purr_script="${BATS_TEST_DIRNAME}/../purr.zsh"
  if [ -f "$purr_script" ]; then
    # shellcheck source=/dev/null
    source "$purr_script"
  fi
}

# Teardown function runs after each test
teardown() {
  # Restore original environment variables
  export HOME="$ORIG_HOME"
  export SSH_AUTH_SOCK="$ORIG_SSH_AUTH_SOCK"
  export PURR_VAULT_NAME="$ORIG_PURR_VAULT_NAME"
  export PURR_GPG_ITEM="$ORIG_PURR_GPG_ITEM"
  export PURR_GITHUB_ITEM="$ORIG_PURR_GITHUB_ITEM"
  export PURR_SSH_AUTH_SOCK="$ORIG_PURR_SSH_AUTH_SOCK"
  export GITHUB_TOKEN="$ORIG_GITHUB_TOKEN"

  # Clean up test directory
  if [ -n "$TEST_TMPDIR" ] && [ -d "$TEST_TMPDIR" ]; then
    rm -rf "$TEST_TMPDIR"
  fi

  # Unset test-specific variables
  unset TEST_TMPDIR
  unset ORIG_HOME
  unset ORIG_SSH_AUTH_SOCK
}

# Helper function to create a mock SSH agent socket
create_mock_ssh_socket() {
  touch "$PURR_SSH_AUTH_SOCK"
  export SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK"
}

# Helper function to remove mock SSH agent socket
remove_mock_ssh_socket() {
  rm -f "$PURR_SSH_AUTH_SOCK"
  unset SSH_AUTH_SOCK
}

# Compatibility wrapper functions for existing tests
setup_test() {
  setup
}

teardown_test() {
  teardown
}
