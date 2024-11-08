Describe 'install.sh'
  Include scripts/install.sh

  Describe '--generate'
    It 'generates distribution install script'
      When call ./scripts/install.sh --generate
      The status should be success
      The output should include '#!/bin/sh'
      The output should include 'VERSION='
      The output should include 'RELEASE_URL='
    End
  End

  Describe '--generate --test'
    It 'generates test install script'
      When call ./scripts/install.sh --generate --test
      The status should be success
      The output should include 'PURR_TEST=1'
      The output should include 'TEST_DIST='
    End
  End
End
