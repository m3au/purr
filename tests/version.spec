#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'version.sh'
  Include src/lib/commands/system/version.sh

  setup() {
    PURR_ROOT="$(mktemp -d)"
    mkdir -p "$PURR_ROOT/.git"
    cd "$PURR_ROOT" || exit 1
  }

  cleanup() {
    rm -rf "$PURR_ROOT"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Mock git
    case "$2" in
      "describe")
        echo "v1.0.0"
        ;;
      "rev-parse")
        echo "abc1234"
        ;;
    esac
  End

  It 'shows version with git info when available'
    When call version_command
    The output should eq "purr version v1.0.0 (abc1234)"
  End

  It 'shows only version with --short flag'
    When call version_command --short
    The output should eq "v1.0.0"
  End

  It 'shows default version when git is not available'
    # Override git mock to fail
    git() { return 1; }
    When call version_command
    The output should eq "purr version 0.0.1"
  End
End
