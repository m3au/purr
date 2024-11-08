#!/usr/bin/env bash

Describe 'Install Script'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  Describe 'Installation'
    Example 'performs a clean installation'
      run_install() {
        bash "$PURR_ROOT/install" 2>&1
      }
      When call run_install
      The status should be success
      The output should include "Installing purr"
      Path "$XDG_DATA_HOME/purr" should be directory
      Path "$XDG_DATA_HOME/purr/bin/purr" should be executable
      Path "$XDG_DATA_HOME/purr/_purr" should be file
      The contents of file "$HOME/.zshrc" should include 'source "${XDG_DATA_HOME:-$HOME/.local/share}/purr/_purr"'
    End

    Example 'fails if already installed'
      run_install_existing() {
        mkdir -p "$XDG_DATA_HOME/purr"
        bash "$PURR_ROOT/install" 2>&1
      }
      When call run_install_existing
      The status should be failure
      The output should include "Existing installation found"
    End
  End

  Describe 'Uninstallation'
    Example 'handles uninstall command'
      run_uninstall() {
        bash "$PURR_ROOT/install" 2>&1
        bash "$PURR_ROOT/install" uninstall 2>&1
      }
      When call run_uninstall
      The status should be success
      The output should include "Uninstalling purr"
      Path "$XDG_DATA_HOME/purr" should not be directory
      The contents of file "$HOME/.zshrc" should not include "purr/_purr"
    End

    Example 'handles uninstall when not installed'
      run_uninstall_clean() {
        bash "$PURR_ROOT/install" uninstall 2>&1
      }
      When call run_uninstall_clean
      The status should be success
      The output should include "purr is not installed"
    End
  End
End
