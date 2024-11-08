#!/bin/sh
# shellcheck shell=bash

Describe 'version.sh'
  Include src/lib/commands/system/version.sh

  BeforeEach 'setup'
  setup() {
    export PURR_VERSION="0.0.1"
  }

  It 'shows detailed version info'
    When call version_command
    The output should eq "purr - key management tool
version: 0.0.1
license: MIT License
website: https://github.com/m3au/purr"
  End

  It 'shows only version number with --short flag'
    When call version_command --short
    The output should eq "0.0.1"
  End

  It 'shows version with v prefix when using --version flag'
    When call version_command --version
    The output should eq "purr - key management tool
version: v0.0.1
license: MIT License
website: https://github.com/m3au/purr"
  End
End
