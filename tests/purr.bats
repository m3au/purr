#!/usr/bin/env bats
# purr.bats - Main test suite for purr functions

load test_helper

@test "purr: help command works" {
  run purr -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage: purr" ]]
  [[ "$output" =~ "Commands:" ]]
}

@test "purr: invalid command shows help and error" {
  run purr invalid-command
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unknown command" ]] || [[ "$output" =~ "Unknown argument" ]]
}

@test "purr: verbose flag is recognized" {
  run purr -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "-v" ]]
}

@test "purr: check command exists" {
  run purr -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "check" ]]
}

@test "purr: lock command exists" {
  run purr -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "lock" ]]
}

@test "purr: configuration variables have defaults" {
  [ -n "${PURR_VAULT_NAME:-}" ] || skip "PURR_VAULT_NAME not set"
  [ -n "${PURR_GPG_ITEM:-}" ] || skip "PURR_GPG_ITEM not set"
  [ -n "${PURR_GITHUB_ITEM:-}" ] || skip "PURR_GITHUB_ITEM not set"
}

@test "purr: configuration can be overridden" {
  export PURR_VAULT_NAME="custom-vault"
  export PURR_GPG_ITEM="custom-gpg"
  export PURR_GITHUB_ITEM="custom-github"
  
  [ "$PURR_VAULT_NAME" = "custom-vault" ]
  [ "$PURR_GPG_ITEM" = "custom-gpg" ]
  [ "$PURR_GITHUB_ITEM" = "custom-github" ]
}
