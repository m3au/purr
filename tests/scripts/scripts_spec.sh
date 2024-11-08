#!/usr/bin/env bash
Describe 'Scripts'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  It 'has all required scripts'
    When call ls scripts/
    The output should include 'completions.sh'
    The output should include 'coverage.sh'
    The output should include 'dist.sh'
    The output should include 'doctor.sh'
    The output should include 'generate-docs.sh'
    The output should include 'publish.sh'
    The output should include 'setup.sh'
    The output should include 'version.sh'
  End

  It 'has executable scripts'
    When call find scripts/ -type f -name "*.sh"
    The output should satisfy eval "for f in $output; do [ -x \"\$f\" ] || exit 1; done"
  End
End
