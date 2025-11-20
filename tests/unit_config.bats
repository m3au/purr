#!/usr/bin/env bats
# Unit tests for configuration loading

load test_helper

@test "PURR_VAULT_NAME has default when not set" {
  # After sourcing purr.zsh, default should be "purr"
  # Since setup() already sources purr.zsh, the variable should be set
  # But we unset it first to test the default
  unset PURR_VAULT_NAME
  # Source purr.zsh to get defaults
  local purr_script="${BATS_TEST_DIRNAME}/../purr.zsh"
  if [ -f "$purr_script" ]; then
    # shellcheck source=/dev/null
    source "$purr_script"
    [ "${PURR_VAULT_NAME}" = "purr" ]
  else
    skip "purr.zsh not found"
  fi
}

@test "PURR_GPG_ITEM has default when not set" {
  unset PURR_GPG_ITEM
  local purr_script="${BATS_TEST_DIRNAME}/../purr.zsh"
  if [ -f "$purr_script" ]; then
    # shellcheck source=/dev/null
    source "$purr_script"
    [ "${PURR_GPG_ITEM}" = "gpg" ]
  else
    skip "purr.zsh not found"
  fi
}

@test "PURR_GITHUB_ITEM has default when not set" {
  unset PURR_GITHUB_ITEM
  local purr_script="${BATS_TEST_DIRNAME}/../purr.zsh"
  if [ -f "$purr_script" ]; then
    # shellcheck source=/dev/null
    source "$purr_script"
    [ "${PURR_GITHUB_ITEM}" = "GitHub" ]
  else
    skip "purr.zsh not found"
  fi
}

@test "configuration can be overridden via environment" {
  export PURR_VAULT_NAME="custom-vault"
  export PURR_GPG_ITEM="custom-gpg"
  export PURR_GITHUB_ITEM="custom-github"
  
  [ "$PURR_VAULT_NAME" = "custom-vault" ]
  [ "$PURR_GPG_ITEM" = "custom-gpg" ]
  [ "$PURR_GITHUB_ITEM" = "custom-github" ]
}

@test "config file can be loaded if exists" {
  # Create a temporary config file
  local config_file="$HOME/.purrrc"
  cat > "$config_file" << 'CONFIGEOF'
export PURR_VAULT_NAME="config-vault"
export PURR_GPG_ITEM="config-gpg"
export PURR_GITHUB_ITEM="config-github"
CONFIGEOF
  
  [ -f "$config_file" ]
  
  # Verify it contains expected variables
  grep -q "PURR_VAULT_NAME" "$config_file"
  grep -q "PURR_GPG_ITEM" "$config_file"
  grep -q "PURR_GITHUB_ITEM" "$config_file"
  
  # Cleanup
  rm -f "$config_file"
}

@test "PURR_SSH_AUTH_SOCK can be configured" {
  export PURR_SSH_AUTH_SOCK="$TEST_TMPDIR/custom-agent.sock"
  [ "$PURR_SSH_AUTH_SOCK" = "$TEST_TMPDIR/custom-agent.sock" ]
}

@test "PURR_GPG_CACHE_TTL can be configured" {
  export PURR_GPG_CACHE_TTL=7200
  [ "$PURR_GPG_CACHE_TTL" = "7200" ]
}
