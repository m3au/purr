#!/usr/bin/env bash
# shellcheck shell=bash

Describe 'version.sh'
  Include lib/modules/commands/system/version.sh

  setup() {
    # Mock git command
    cat > "${SHELLSPEC_TMPDIR}/git" << "EOF"
#!/bin/sh
case "$1" in
  "rev-parse") echo "abc1234" ;;
  "describe") echo "v1.0.0" ;;
  *) exit 1 ;;
esac
EOF
    chmod +x "${SHELLSPEC_TMPDIR}/git"
    export PATH="${SHELLSPEC_TMPDIR}:$PATH"
    export PURR_ROOT="${SHELLSPEC_TMPDIR}"
    mkdir -p "${SHELLSPEC_TMPDIR}/.git"
  }

  cleanup() {
    rm -f "${SHELLSPEC_TMPDIR}/git"
    rm -rf "${SHELLSPEC_TMPDIR}/.git"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'version_command'
    It 'shows version with git info when available'
      When call version_command
      The output should eq "purr version v1.0.0 (abc1234)"
    End

    It 'shows only version with --short flag'
      When call version_command --short
      The output should eq "v1.0.0"
    End

    It 'shows default version when git is not available'
      rm "${SHELLSPEC_TMPDIR}/git"
      When call version_command
      The output should eq "purr version 0.0.1"
    End
  End
End
