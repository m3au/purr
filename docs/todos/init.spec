#!/bin/sh

Describe 'install command'
  setup() {
    export XDG_DATA_HOME="$TMPDIR/local/share"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
  }

  cleanup() {
    rm -rf "$TMPDIR"/*
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'creates correct directory structure'
    When call purr install
    The status should be success
    The directory "$XDG_DATA_HOME/purr" should exist
    The directory "$XDG_DATA_HOME/purr/bin" should exist
    The directory "$XDG_DATA_HOME/purr/lib" should exist
    The file "$XDG_DATA_HOME/purr/_purr" should exist
  End

  It 'installs required files'
    When call purr install
    The status should be success
    The file "$XDG_DATA_HOME/purr/bin/purr" should exist
    The file "$XDG_DATA_HOME/purr/bin/purr" should be executable
  End

  It 'creates default configuration'
    When call purr install
    The status should be success
    The file "$XDG_CONFIG_HOME/purr/config" should exist
  End

  It 'preserves existing configuration during reinstall'
    mkdir -p "$XDG_CONFIG_HOME/purr"
    echo "test_setting=value" > "$XDG_CONFIG_HOME/purr/config"

    When call purr install
    The status should be success
    The file "$XDG_CONFIG_HOME/purr/config" should contain "test_setting=value"
  End

  It 'sets correct permissions'
    When call purr install
    The status should be success
    The file "$XDG_DATA_HOME/purr/_purr" should have permission 600
    The file "$XDG_CONFIG_HOME/purr/config" should have permission 600
  End

  It 'creates backup of existing installation'
    # First installation
    When call purr install
    The status should be success

    # Create test data
    echo "test data" > "$XDG_DATA_HOME/purr/test.txt"

    # Reinstall
    When call purr install
    The status should be success
    The directory "$XDG_DATA_HOME/purr.bak" should exist
    The file "$XDG_DATA_HOME/purr.bak/test.txt" should exist
  End

  It 'handles development mode installation'
    When call purr install --dev
    The status should be success
    The file "$XDG_DATA_HOME/purr/bin/purr" should be symlink
    The file "$XDG_DATA_HOME/purr/lib" should be symlink
  End
End
