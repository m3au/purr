#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'install.sh'
  Include src/lib/commands/system/install.sh

  setup() {
    TEST_DIR="$(mktemp -d)"
    ORIGINAL_HOME="$HOME"
    HOME="$TEST_DIR/home"
    PREFIX="$TEST_DIR/usr/local"
    PURR_ROOT="$TEST_DIR/purr"

    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_CACHE_HOME="$HOME/.cache"
    export SYSTEM_CONFIG_DIR="$TEST_DIR/etc/purr"

    mkdir -p "$HOME"
    mkdir -p "$PREFIX/bin"
    mkdir -p "$PURR_ROOT/src/lib/core"
    mkdir -p "$PURR_ROOT/src/lib/commands"
    mkdir -p "$PURR_ROOT/scripts"
    mkdir -p "$PURR_ROOT/config"
    touch "$PURR_ROOT/lib/purr"
    touch "$PURR_ROOT/scripts/completion.sh"
    touch "$PURR_ROOT/config/purr.conf.default"
    touch "$PURR_ROOT/config/user.conf.default"
    touch "$HOME/.zshrc"

    check_dir_mode() { [ "$(stat -f '%p' "$1")" = "$2" ]; }
    check_file_mode() { [ "$(stat -f '%p' "$1")" = "$2" ]; }
  }

  cleanup() {
    HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_DIR"
    unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME SYSTEM_CONFIG_DIR
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'creates user directories with correct permissions'
    When call install_command
    The path "$HOME/.config/purr" should be directory
    The path "$HOME/.local/share/purr" should be directory
    The path "$HOME/.cache/purr" should be directory
    Assert check_dir_mode "$HOME/.config/purr" "40700"
    Assert check_dir_mode "$HOME/.local/share/purr" "40700"
    Assert check_dir_mode "$HOME/.cache/purr" "40700"
  End

  It 'creates system directories when run as root'
    Mock id
      echo "0"
    End
    When call install_command
    The path "$PREFIX/bin" should be directory
    The path "$PREFIX/lib/purr" should be directory
    The path "$SYSTEM_CONFIG_DIR" should be directory
  End

  It 'installs executable with correct permissions'
    Mock id
      echo "0"
    End
    When call install_command
    The path "$PREFIX/bin/purr" should be file
    Assert check_file_mode "$PREFIX/bin/purr" "100755"
  End

  It 'installs user config with correct permissions'
    When call install_command
    The path "$HOME/.config/purr/config" should be file
    Assert check_file_mode "$HOME/.config/purr/config" "100600"
  End

  It 'updates shell configuration'
    When call install_command
    The contents of file "$HOME/.zshrc" should include "PURR_CONFIG_HOME"
    The contents of file "$HOME/.zshrc" should include "PURR_DATA_HOME"
    The contents of file "$HOME/.zshrc" should include "PURR_CACHE_HOME"
  End

  It 'fails when system directories are not writable'
    Mock id
      echo "0"
    End
    chmod 000 "$PREFIX/bin"
    When call install_command
    The status should be failure
    The stderr should include "Failed to create system directories"
    chmod 755 "$PREFIX/bin"
  End
End
