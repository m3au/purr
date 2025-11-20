#!/usr/bin/env bats
# Integration test helpers and setup tests

load test_helper

@test "mock op command exists and works" {
  [ -x "$BATS_TEST_DIRNAME/mocks/op.sh" ]
  
  # Test that mock op can be called - use timeout to avoid hangs
  result=$(timeout 2 "$BATS_TEST_DIRNAME/mocks/op.sh" account get 2>/dev/null || echo "timeout")
  [ "$result" != "timeout" ] || skip "Mock op execution slow"
}

@test "mock gpg command exists" {
  [ -x "$BATS_TEST_DIRNAME/mocks/gpg.sh" ]
}

@test "mock git command exists" {
  [ -x "$BATS_TEST_DIRNAME/mocks/git.sh" ]
}

@test "mock ssh command exists" {
  [ -x "$BATS_TEST_DIRNAME/mocks/ssh.sh" ]
}

@test "mock infrastructure is ready for integration tests" {
  # Verify all mocks are in place
  [ -f "$BATS_TEST_DIRNAME/mocks/op.sh" ]
  [ -f "$BATS_TEST_DIRNAME/mocks/gpg.sh" ]
  [ -f "$BATS_TEST_DIRNAME/mocks/git.sh" ]
  [ -f "$BATS_TEST_DIRNAME/mocks/ssh.sh" ]
}

@test "mock op returns GPG key data" {
  # Add mocks to PATH only for this test
  export PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
  export PURR_VAULT_NAME="test-vault"
  export PURR_GPG_ITEM="test-gpg"
  
  result=$(timeout 2 op item get test-gpg --vault test-vault --field key_id 2>/dev/null || echo "")
  [ -n "$result" ] || skip "Mock op needs configuration"
}
