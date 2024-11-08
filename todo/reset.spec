#!/bin/sh
# shellcheck shell=bash

Describe 'reset.sh'
    Include src/lib/commands/system/reset.sh

    setup() {
        TEST_CONFIG_DIR=""
        TEST_BACKUP_DIR=""

        # Create temporary test directories
        TEST_CONFIG_DIR="$(mktemp -d)"
        TEST_BACKUP_DIR="$(mktemp -d)"

        # Override real config/backup dirs with test dirs
        # shellcheck disable=SC2034
        config_dir="$TEST_CONFIG_DIR"
        # shellcheck disable=SC2034
        backup_dir="$TEST_BACKUP_DIR"

        # Create some test files
        mkdir -p "$config_dir"
        echo "test" > "$config_dir/test.conf"
    }

    cleanup() {
        rm -rf "$TEST_CONFIG_DIR"
        rm -rf "$TEST_BACKUP_DIR"
    }

    BeforeEach 'setup'
    AfterEach 'cleanup'

    It 'should create backup of existing config'
        reset_config
        Assert test -d "$backup_dir"
        Assert test -f "$backup_dir"/config_*/test.conf
    End

    It 'should remove existing config'
        reset_config
        Assert test ! -f "$config_dir/test.conf"
    End

    It 'should create fresh config directory'
        rm -rf "$config_dir"
        reset_config
        Assert test -d "$config_dir"
    End
End
