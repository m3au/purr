#!/usr/bin/env bash

Describe 'Make Commands'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  Describe 'Installation'
    Before 'clean_existing_installation'

    clean_existing_installation() {
      rm -rf "$XDG_DATA_HOME/purr" || true
      if [ -f "$HOME/.zshrc" ]; then
        sed -i.bak '/purr\/_purr/d' "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.bak"
      fi
    }

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

  Describe 'Documentation targets'
    It 'has background target'
      When call make -n background
      The status should be success
      The output should include 'generate-docs.sh background'
    End

    It 'has context target'
      When call make -n context
      The status should be success
      The output should include 'generate-docs.sh context'
    End
  End
End
