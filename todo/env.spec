#!/bin/sh
# shellcheck shell=bash

Describe 'env.sh'
  Include src/lib/core/env.sh

  Describe 'validate_env()'
    setup_env() { PURR_HOME="${SHELLSPEC_TMPDIR}/purr_test"; mkdir -p "$PURR_HOME"; }
    cleanup_env() { rm -rf "${SHELLSPEC_TMPDIR}/purr_test"; }
    BeforeEach 'setup_env'
    AfterEach 'cleanup_env'

    It 'succeeds when PURR_HOME is set and directory exists'
      When call validate_env
      The status should be success
      The output should include 'Environment validated'
    End

    It 'fails when PURR_HOME is not set'
      unset PURR_HOME
      When call validate_env
      The status should be failure
      The error should include 'PURR_HOME environment variable not set'
    End

    It 'fails when PURR_HOME directory does not exist'
      PURR_HOME="/nonexistent/path"
      When call validate_env
      The status should be failure
      The error should include 'PURR_HOME directory does not exist'
    End
  End

  Describe 'check_required_commands()'
    It 'succeeds when all required commands exist'
      When call check_required_commands 'ls' 'cat' 'echo'
      The status should be success
      The output should include 'All required commands found'
    End

    It 'fails when a required command is missing'
      When call check_required_commands 'nonexistentcommand123'
      The status should be failure
      The error should include 'Required command not found'
    End

    It 'checks multiple commands and fails on first missing one'
      When call check_required_commands 'ls' 'nonexistentcommand123' 'cat'
      The status should be failure
      The error should include 'Required command not found'
    End
  End
End
