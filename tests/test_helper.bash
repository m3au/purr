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
  export ORIG_GIT_CONFIG_GLOBAL="${GIT_CONFIG_GLOBAL-}"
  export ORIG_GNUPGHOME="${GNUPGHOME-}"

  # Set test environment variables
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME/.ssh"
  mkdir -p "$HOME/.gnupg"
  mkdir -p "$HOME/.cursor"
  # Keep git and gpg state inside the temp home, even if the outer environment
  # points at a real GNUPGHOME or GIT_CONFIG_GLOBAL.
  export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  export GNUPGHOME="$HOME/.gnupg"

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

  if type purr_test_after_setup >/dev/null 2>&1; then
    purr_test_after_setup
  fi
}

# Teardown function runs after each test
teardown() {
  # Stop a fake SSH agent socket before deleting its directory.
  if [ -n "${TEST_TMPDIR:-}" ] && [ -f "$TEST_TMPDIR/sock.pid" ]; then
    kill "$(cat "$TEST_TMPDIR/sock.pid")" 2>/dev/null || true
    wait "$(cat "$TEST_TMPDIR/sock.pid")" 2>/dev/null || true
  fi

  # Restore original environment variables
  export HOME="$ORIG_HOME"
  export SSH_AUTH_SOCK="$ORIG_SSH_AUTH_SOCK"
  export PURR_VAULT_NAME="$ORIG_PURR_VAULT_NAME"
  export PURR_GPG_ITEM="$ORIG_PURR_GPG_ITEM"
  export PURR_GITHUB_ITEM="$ORIG_PURR_GITHUB_ITEM"
  export PURR_SSH_AUTH_SOCK="$ORIG_PURR_SSH_AUTH_SOCK"
  export GITHUB_TOKEN="$ORIG_GITHUB_TOKEN"
  if [ -n "$ORIG_GIT_CONFIG_GLOBAL" ]; then
    export GIT_CONFIG_GLOBAL="$ORIG_GIT_CONFIG_GLOBAL"
  else
    unset GIT_CONFIG_GLOBAL
  fi
  if [ -n "$ORIG_GNUPGHOME" ]; then
    export GNUPGHOME="$ORIG_GNUPGHOME"
  else
    unset GNUPGHOME
  fi
  unset GIT_CONFIG_NOSYSTEM

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
