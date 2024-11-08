#!/usr/bin/env shellspec

# Helper functions
verify_test_archive() {
  local archive="tests/dev/dist/purr-test.tar.gz"
  if [ ! -f "$archive" ]; then
    return 1
  fi
  tar -tzf "$archive"
}

verify_release_archive() {
  local version=$(cat VERSION)
  local archive="dist/purr-${version}.tar.gz"
  if [ ! -f "$archive" ]; then
    return 1
  fi
  tar -tzf "$archive"
}

run_release_patch() {
    ./scripts/version.sh patch
}

run_release_minor() {
    ./scripts/version.sh minor
}

run_release_major() {
    ./scripts/version.sh major
}

Describe 'Publishing Process'
  setup() {
    # Create required directories
    mkdir -p dist/man
    mkdir -p dist/completion
    mkdir -p tests/dev/dist/man
    mkdir -p tests/dev/dist/completion
    # Create dummy man page
    echo "dummy man page" > dist/man/purr.1
    echo "dummy man page" > tests/dev/dist/man/purr.1
    # Create dummy version
    echo "0.0.0" > VERSION
  }

  cleanup() {
    rm -rf dist tests/dev/dist
    rm -f VERSION
  }

  Before 'setup'
  After 'cleanup'

  Describe 'Distribution'
    It 'creates test distribution archive'
      When run make test-dist
      The status should be success
      The path "tests/dev/dist/purr-test.tar.gz" should be file
    End

    It 'creates release distribution archive'
      When run make dist
      The status should be success
      The path "dist/purr-0.0.0.tar.gz" should be file
    End
  End

  Describe 'Version Management'
    It 'increments patch version'
      When call run_release_patch
      The status should be success
      The contents of file "VERSION" should equal "0.0.1"
    End

    It 'increments minor version'
      When call run_release_minor
      The status should be success
      The contents of file "VERSION" should equal "0.1.0"
    End

    It 'increments major version'
      When call run_release_major
      The status should be success
      The contents of file "VERSION" should equal "1.0.0"
    End
  End

  Describe 'Archive Contents'
    Describe 'Test Distribution'
      It 'creates archive'
        When run make test-dist
        The status should be success
        The path "tests/dev/dist/purr-test.tar.gz" should be file
      End

      It 'has correct structure'
        When call verify_test_archive
        The status should be success
        The output should include "man/purr.1"
        The output should include "completion/completion.bash"
        The output should include "completion/completion.zsh"
      End
    End

    Describe 'Release Distribution'
      It 'creates archive'
        When run make dist
        The status should be success
        The path "dist/purr-0.0.0.tar.gz" should be file
      End

      It 'has correct structure'
        When call verify_release_archive
        The status should be success
        The output should include "man/purr.1"
        The output should include "completion/completion.bash"
        The output should include "completion/completion.zsh"
      End
    End
  End
End
