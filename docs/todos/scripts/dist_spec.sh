#!/usr/bin/env bash
Describe 'dist.sh'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_dist() {
    mkdir -p dist/{man,completion}
    mkdir -p tests/dev/dist/{man,completion}

    touch dist/man/purr.1
    touch dist/completion/completion.{zsh,bash}

    mkdir -p src/{bin,lib}
    touch src/bin/purr
    chmod +x src/bin/purr
  }

  BeforeEach 'setup_dist'

  It 'creates release distribution'
    When run script ./scripts/dist.sh 1.0.0 release
    The status should be success
    The path 'dist/purr-1.0.0.tar.gz' should be file
    The output should include 'Creating release distribution archive'
  End

  It 'creates test distribution'
    When run script ./scripts/dist.sh 1.0.0 test
    The status should be success
    The path 'tests/dev/dist/purr-test.tar.gz' should be file
    The output should include 'Creating test distribution archive'
  End
End
