#!/usr/bin/env shellspec

Describe 'Install Script'
  setup() {
    TEMP_HOME=$(mktemp -d)
    export HOME="$TEMP_HOME"
    export XDG_DATA_HOME="$HOME/.local/share"
    mkdir -p "$XDG_DATA_HOME"
  }

  cleanup() {
    rm -rf "$TEMP_HOME"
  }

  Describe 'Installation'
    Before 'setup'
    After 'cleanup'

    It 'performs a clean installation'
      When call run_install
      The status should be success
      The path "$XDG_DATA_HOME/purr" should be directory
      The path "$XDG_DATA_HOME/purr/_purr" should be file
      The path "$HOME/.zshrc" should be file
      The contents of file "$HOME/.zshrc" should include "source \"\${XDG_DATA_HOME:-\$HOME/.local/share}/purr/_purr\""
    End

    It 'fails if already installed'
      mkdir -p "$XDG_DATA_HOME/purr"
      When call run_install
      The status should be failure
      The output should include "purr is already installed"
    End
  End

  Describe 'Uninstallation'
    Before 'setup'
    After 'cleanup'

    It 'handles uninstall command'
      mkdir -p "$XDG_DATA_HOME/purr"
      touch "$XDG_DATA_HOME/purr/_purr"
      When call run_uninstall
      The status should be success
      The path "$XDG_DATA_HOME/purr" should not exist
    End

    It 'handles uninstall when not installed'
      When call run_uninstall_clean
      The status should be success
      The output should include "purr is not installed"
    End
  End
End
