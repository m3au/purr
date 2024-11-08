#!/bin/sh

Describe 'uninstall.sh'
  Include src/lib/commands/system/uninstall.sh

  setup() {
    TEST_DIR="$(mktemp -d)"
    ORIGINAL_HOME="$HOME"
    HOME="$TEST_DIR/home"
    PREFIX="$TEST_DIR/usr/local"

    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_CACHE_HOME="$HOME/.cache"

    mkdir -p "$PREFIX/bin"
    mkdir -p "$PREFIX/lib/purr"
    mkdir -p "$HOME/.config/purr"
    mkdir -p "$HOME/.local/share/purr"
    mkdir -p "$HOME/.cache/purr"
    touch "$PREFIX/bin/purr"
    echo "# purr configuration" > "$HOME/.zshrc"
    echo "export PURR_CONFIG_HOME=\"\${XDG_CONFIG_HOME:-\$HOME/.config}/purr\"" >> "$HOME/.zshrc"
  }

  cleanup() {
    HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
    unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'removes executable'
    When call uninstall_command
    The file "$PREFIX/bin/purr" should not exist
  End

  It 'removes shell configuration'
    When call uninstall_command
    The file "$HOME/.zshrc" should not include "PURR_CONFIG_HOME"
  End

  It 'removes user directories when confirmed'
    echo "y" | When call uninstall_command
    The directory "$HOME/.config/purr" should not exist
    The directory "$HOME/.local/share/purr" should not exist
    The directory "$HOME/.cache/purr" should not exist
  End

  It 'keeps user directories when not confirmed'
    echo "n" | When call uninstall_command
    The directory "$HOME/.config/purr" should exist
    The directory "$HOME/.local/share/purr" should exist
    The directory "$HOME/.cache/purr" should exist
  End

  It 'fails gracefully when executable is not writable'
    chmod 000 "$PREFIX/bin/purr"
    When call uninstall_command
    The status should be failure
    The stderr should include "Failed to remove executable"
    chmod 755 "$PREFIX/bin/purr"
  End

  It 'runs lock command before uninstalling'
    lock_command() { echo "lock_command called"; return 0; }
    When call uninstall_command
    The stdout should include "lock_command called"
  End
End
