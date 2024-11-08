#!/bin/bash

set -eu

DEBUG="${DEBUG:-0}"
DEV_DIR="tests/dev"

setup_directories() {
    local verbose=""
    [ "$DEBUG" = "1" ] && verbose="-v"

    # Create development directories
    mkdir -p $verbose "$DEV_DIR"/.config/purr
    mkdir -p $verbose "$DEV_DIR"/.local/share/purr/backups
    mkdir -p $verbose "$DEV_DIR"/.cache/purr
    mkdir -p $verbose "$DEV_DIR"/.local/share/zsh/site-functions
    mkdir -p $verbose "$DEV_DIR"/dist/{man,completion}
    mkdir -p $verbose dist/{man,completion}

    # Create source directories
    mkdir -p $verbose src/{bin,lib,completion}

    # Create test directories
    mkdir -p $verbose tests/scripts
}

setup_dependencies() {
    command -v shellcheck >/dev/null || brew install shellcheck
    command -v shfmt >/dev/null || brew install shfmt
    command -v kcov >/dev/null || brew install kcov
    command -v go-md2man >/dev/null || brew install go-md2man
    command -v shellspec >/dev/null || brew install shellspec
}

show_environment() {
    [ "$DEBUG" = "1" ] || return 0

    echo "Setting up development environment..."
    echo "Environment variables set:"
    echo "  PURR_DEV_MODE=$PURR_DEV_MODE"
    echo "  PURR_ROOT=$PURR_ROOT"
    echo "  PURR_LIB=$PURR_LIB"
    echo "  PURR_BIN=$PURR_BIN"
    echo "  XDG_CONFIG_HOME=$XDG_CONFIG_HOME"
    echo "  XDG_DATA_HOME=$XDG_DATA_HOME"
    echo "  XDG_CACHE_HOME=$XDG_CACHE_HOME"
}

setup_directories
setup_dependencies
show_environment
