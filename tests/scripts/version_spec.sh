#!/usr/bin/env bash
Describe 'version.sh'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_version() {
    echo "0.0.0" > VERSION
  }

  BeforeEach 'setup_version'

  It 'shows current version'
    When run script ./scripts/version.sh
    The status should be success
    The output should eq "0.0.0"
  End

  It 'increments patch version'
    When run script ./scripts/version.sh patch
    The status should be success
    The output should eq "0.0.1"
  End

  It 'increments minor version'
    When run script ./scripts/version.sh minor
    The status should be success
    The output should eq "0.1.0"
  End

  It 'increments major version'
    When run script ./scripts/version.sh major
    The status should be success
    The output should eq "1.0.0"
  End
End
