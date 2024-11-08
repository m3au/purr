#!/usr/bin/env bash

Describe 'Install Script'
  setup() {
    TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export XDG_DATA_HOME="$TEST_HOME/.local/share"
    export SHELL="/bin/zsh"
    export QUIET=0
    export PURR_TEST=1

    mkdir -p "$XDG_DATA_HOME"
    chmod -R 755 "$TEST_HOME"
    touch "$HOME/.zshrc"

    ORIG_PWD="$PWD"
    cd "$PURR_ROOT" || exit 1
  }

  cleanup() {
    cd "$ORIG_PWD" || exit 1
    if [ -d "$TEST_HOME" ]; then
      chmod -R 755 "$TEST_HOME" 2>/dev/null || true
      rm -rf "$TEST_HOME"
    fi
    unset HOME XDG_DATA_HOME SHELL QUIET ORIG_PWD PURR_TEST
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

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
