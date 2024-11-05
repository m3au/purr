#!/usr/bin/env bats

load '../.bats/test_helper'

setup() {
    # Load the main script before each test
    source "$(pwd)/init.zsh"
}

@test "colorize function exists" {
    run type colorize
    assert_success
    assert_output --partial "colorize is a function"
}

@test "obfuscate_key function exists" {
    run type obfuscate_key
    assert_success
    assert_output --partial "obfuscate_key is a function"
}

@test "purr function exists" {
    run type purr
    assert_success
    assert_output --partial "purr is a function"
}
