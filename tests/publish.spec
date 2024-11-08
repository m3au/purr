#!/usr/bin/env bash

Describe 'Publishing Process'
  setup() {
    # Create temporary test directories
    TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export XDG_DATA_HOME="$TEST_HOME/.local/share"
    export SHELLSPEC_TMPDIR="$TEST_HOME/tmp"
    mkdir -p "$SHELLSPEC_TMPDIR"

    # Store current directory
    ORIG_PWD="$PWD"
    cd "$PURR_ROOT" || exit 1

    # Create required files if they don't exist
    [ -f "LICENSE" ] || touch LICENSE
    [ -f "README.md" ] || touch README.md
    [ -f "VERSION" ] || echo "0.0.0" > VERSION

    # Ensure test environment
    export SKIP_GIT=1
    export SKIP_TEST=1  # Skip running tests during release
  }

  cleanup() {
    cd "$ORIG_PWD" || exit 1
    if [ -d "$TEST_HOME" ]; then
      rm -rf "$TEST_HOME"
    fi
    # Clean up test artifacts
    rm -f VERSION
    rm -rf dist
    rm -rf tests/dev/dist
    unset HOME XDG_DATA_HOME ORIG_PWD SHELLSPEC_TMPDIR SKIP_GIT SKIP_TEST
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'Distribution'
    Example 'creates test distribution archive'
      When run make test-dist
      The status should be success
      Path "tests/dev/dist/purr-test.tar.gz" should be file
      The output should include "Creating test distribution archive"
    End

    Example 'creates release distribution archive'
      When run make dist
      The status should be success
      Path "dist/purr-0.0.0.tar.gz" should be file
      The output should include "Creating distribution archive"
    End
  End

  Describe 'Version Management'
    Example 'increments patch version'
      run_release_patch() {
        echo "0.0.0" > VERSION
        make release-patch
      }
      When call run_release_patch
      The status should be success
      The output should include "Publishing version 0.0.1"
      The contents of file "VERSION" should equal "0.0.1"
    End

    Example 'increments minor version'
      run_release_minor() {
        echo "0.0.0" > VERSION
        make release-minor
      }
      When call run_release_minor
      The status should be success
      The output should include "Publishing version 0.1.0"
      The contents of file "VERSION" should equal "0.1.0"
    End

    Example 'increments major version'
      run_release_major() {
        echo "0.0.0" > VERSION
        make release-major
      }
      When call run_release_major
      The status should be success
      The output should include "Publishing version 1.0.0"
      The contents of file "VERSION" should equal "1.0.0"
    End
  End

  Describe 'Archive Contents'
    Describe 'Test Distribution'
      Example 'creates archive'
        When run make test-dist
        The status should be success
        The output should include "Creating test distribution archive"
        Path "tests/dev/dist/purr-test.tar.gz" should be file
      End

      Example 'has correct structure'
        # Create archive first
        make test-dist >/dev/null 2>&1

        verify_test_archive() {
          local tmp_dir="$TEST_HOME/extract"
          mkdir -p "$tmp_dir"
          cp "tests/dev/dist/purr-test.tar.gz" "$tmp_dir/"
          cd "$tmp_dir" || return 1
          tar xzf "purr-test.tar.gz"

          [ -d "purr-test" ] || return 1
          [ -d "purr-test/src" ] || return 1
          [ -f "purr-test/LICENSE" ] || return 1
          [ -f "purr-test/README.md" ] || return 1
          [ -f "purr-test/VERSION" ] || return 1
          [ -f "purr-test/install" ] || return 1
          [ -x "purr-test/src/bin/purr" ] || return 1
        }
        When call verify_test_archive
        The status should be success
      End
    End

    Describe 'Release Distribution'
      Example 'creates archive'
        When run make dist
        The status should be success
        The output should include "Creating distribution archive"
        Path "dist/purr-0.0.0.tar.gz" should be file
      End

      Example 'has correct structure'
        # Create archive first
        make dist >/dev/null 2>&1

        verify_release_archive() {
          local tmp_dir="$TEST_HOME/extract"
          mkdir -p "$tmp_dir"
          cp "dist/purr-0.0.0.tar.gz" "$tmp_dir/"
          cd "$tmp_dir" || return 1
          tar xzf "purr-0.0.0.tar.gz"

          [ -d "purr-0.0.0" ] || return 1
          [ -d "purr-0.0.0/src" ] || return 1
          [ -f "purr-0.0.0/LICENSE" ] || return 1
          [ -f "purr-0.0.0/README.md" ] || return 1
          [ -f "purr-0.0.0/VERSION" ] || return 1
          [ -f "purr-0.0.0/install" ] || return 1
          [ -x "purr-0.0.0/src/bin/purr" ] || return 1
        }
        When call verify_release_archive
        The status should be success
      End
    End
  End
End
