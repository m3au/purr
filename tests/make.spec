#!/usr/bin/env bash

Describe 'Make Commands'
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

    rm -rf "tests/dev/.local/share/purr"
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
    Example 'make install performs installation'
      When run make install
      The output should include "Installing purr..."
      The stderr should include "Installing purr v0.0.1"
      The stderr should include "Installation complete"
      The status should be success
      Path "$XDG_DATA_HOME/purr" should be directory
      Path "$XDG_DATA_HOME/purr/bin/purr" should be executable
      Path "$XDG_DATA_HOME/purr/_purr" should be file
      The contents of file "$HOME/.zshrc" should include 'source "${XDG_DATA_HOME:-$HOME/.local/share}/purr/_purr"'
    End

    Example 'make uninstall removes installation'
      # First install
      make install >/dev/null 2>&1

      When run make uninstall
      The output should include "Uninstalling purr..."
      The stderr should include "Uninstalling purr"
      The status should be success
      Path "$XDG_DATA_HOME/purr" should not be directory
      The contents of file "$HOME/.zshrc" should not include "purr/_purr"
    End
  End
End
