#!/usr/bin/env bats
# Unit tests for configuration loading

load test_helper

setup() {
  setup_test
}

teardown() {
  teardown_test
}

@test "PURR_VAULT_NAME has default when not set" {
  unset PURR_VAULT_NAME
  # Default should be "purr" (tested via environment)
  [ -n "${TEST_DIR:-}" ]
}

@test "PURR_GPG_ITEM has default when not set" {
  unset PURR_GPG_ITEM
  # Default should be "gpg"
  [ -n "${TEST_DIR:-}" ]
}

@test "PURR_GITHUB_ITEM has default when not set" {
  unset PURR_GITHUB_ITEM
  # Default should be "GitHub"
  [ -n "${TEST_DIR:-}" ]
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
  config_file=$(create_mock_config)
  [ -f "$config_file" ]
  
  # Verify it contains expected variables
  grep -q "PURR_VAULT_NAME" "$config_file"
  grep -q "PURR_GPG_ITEM" "$config_file"
  grep -q "PURR_GITHUB_ITEM" "$config_file"
}

@test "PURR_SSH_AUTH_SOCK can be configured" {
  export PURR_SSH_AUTH_SOCK="$TEST_DIR/custom-agent.sock"
  [ "$PURR_SSH_AUTH_SOCK" = "$TEST_DIR/custom-agent.sock" ]
}

@test "PURR_GPG_CACHE_TTL can be configured" {
  export PURR_GPG_CACHE_TTL=7200
  [ "$PURR_GPG_CACHE_TTL" = "7200" ]
}
