#!/usr/bin/env bash

Describe 'Publishing Process'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

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
          [ -f "purr-0.0.0/src/completion/completion.zsh" ] || return 1
          [ -f "purr-0.0.0/src/completion/completion.bash" ] || return 1
        }
        When call verify_release_archive
        The status should be success
      End
    End
  End
End
