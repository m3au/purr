#!/usr/bin/env bats
# shellcheck disable=SC2034

# Test helper for purr tests
# Provides common setup and teardown functions

# Load the purr script for testing
# Note: In a real test environment, you would source purr.zsh
# For now, we'll create mock versions of functions

setup() {
  # Create temporary directory for tests
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  
  # Backup original environment variables
  export PURR_VAULT_NAME_ORIG="${PURR_VAULT_NAME:-}"
  export PURR_GPG_ITEM_ORIG="${PURR_GPG_ITEM:-}"
  export PURR_GITHUB_ITEM_ORIG="${PURR_GITHUB_ITEM:-}"
  export PURR_SSH_AUTH_SOCK_ORIG="${PURR_SSH_AUTH_SOCK:-}"
  export PURR_GPG_CACHE_TTL_ORIG="${PURR_GPG_CACHE_TTL:-}"
  
  # Set test environment variables
  export PURR_VAULT_NAME="test-vault"
  export PURR_GPG_ITEM="test-gpg"
  export PURR_GITHUB_ITEM="test-github"
  export PURR_SSH_AUTH_SOCK="$TEST_DIR/agent.sock"
  export PURR_GPG_CACHE_TTL=3600
  
  # Create mock SSH socket for testing
  mkdir -p "$(dirname "$PURR_SSH_AUTH_SOCK")"
  touch "$PURR_SSH_AUTH_SOCK"
}

teardown() {
  # Restore original environment variables
  if [ -n "$PURR_VAULT_NAME_ORIG" ]; then
    export PURR_VAULT_NAME="$PURR_VAULT_NAME_ORIG"
  else
    unset PURR_VAULT_NAME
  fi
  
  if [ -n "$PURR_GPG_ITEM_ORIG" ]; then
    export PURR_GPG_ITEM="$PURR_GPG_ITEM_ORIG"
  else
    unset PURR_GPG_ITEM
  fi
  
  if [ -n "$PURR_GITHUB_ITEM_ORIG" ]; then
    export PURR_GITHUB_ITEM="$PURR_GITHUB_ITEM_ORIG"
  else
    unset PURR_GITHUB_ITEM
  fi
  
  if [ -n "$PURR_SSH_AUTH_SOCK_ORIG" ]; then
    export PURR_SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK_ORIG"
  else
    unset PURR_SSH_AUTH_SOCK
  fi
  
  if [ -n "$PURR_GPG_CACHE_TTL_ORIG" ]; then
    export PURR_GPG_CACHE_TTL="$PURR_GPG_CACHE_TTL_ORIG"
  else
    unset PURR_GPG_CACHE_TTL
  fi
  
  # Clean up test directory
  rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Helper function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Helper function to create mock config file
create_mock_config() {
  local config_file="$TEST_DIR/.purrrc"
  cat > "$config_file" << EOF
export PURR_VAULT_NAME="custom-vault"
export PURR_GPG_ITEM="custom-gpg"
export PURR_GITHUB_ITEM="custom-github"
EOF
  echo "$config_file"
}


# Load assertion utilities
load_assertions() {
  # Source assertion utilities if available
  if [ -f "$BATS_TEST_DIRNAME/utils/assertions.bash" ]; then
    source "$BATS_TEST_DIRNAME/utils/assertions.bash"
  fi
}

# Setup assertions in setup
setup_assertions() {
  load_assertions
}
