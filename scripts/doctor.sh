#!/bin/bash

set -eu

check_directories() {
    echo "- Directory structure:"
    [ -d "tests/dev/.config/purr" ] && echo "✓ Config directory exists" || echo "✗ Missing config directory"
    [ -d "tests/dev/.local/share/purr/backups" ] && echo "✓ Data directory exists" || echo "✗ Missing data directory"
    [ -d "tests/dev/.cache/purr" ] && echo "✓ Cache directory exists" || echo "✗ Missing cache directory"
}

check_dependencies() {
    echo "- Development dependencies:"
    command -v shellcheck >/dev/null && echo "✓ shellcheck installed" || echo "✗ shellcheck missing"
    command -v shfmt >/dev/null && echo "✓ shfmt installed" || echo "✗ shfmt missing"
    command -v kcov >/dev/null && echo "✓ kcov installed" || echo "✗ kcov missing"
    command -v go-md2man >/dev/null && echo "✓ go-md2man installed" || echo "✗ go-md2man missing"
}

check_permissions() {
    echo "- File permissions:"
    find "tests" -name "*_spec.sh" -perm +111 -print | grep -q . && echo "✓ Test files are executable" || echo "✗ Test files not executable"
    [ -d "src/bin" ] && find "src/bin" -type f -perm +111 -print | grep -q . && echo "✓ Binary files are executable" || echo "✗ Binary files not executable"
}

check_environment() {
    echo "- Environment variables:"
    [ "$PURR_DEV_MODE" = "true" ] && echo "✓ PURR_DEV_MODE is set" || echo "✗ PURR_DEV_MODE not set"
    [ -n "$PURR_ROOT" ] && echo "✓ PURR_ROOT is set" || echo "✗ PURR_ROOT not set"
    [ -n "$PURR_LIB" ] && echo "✓ PURR_LIB is set" || echo "✗ PURR_LIB not set"
    [ -n "$PURR_BIN" ] && echo "✓ PURR_BIN is set" || echo "✗ PURR_BIN not set"
    [ -n "$XDG_CONFIG_HOME" ] && echo "✓ XDG_CONFIG_HOME is set" || echo "✗ XDG_CONFIG_HOME not set"
    [ -n "$XDG_DATA_HOME" ] && echo "✓ XDG_DATA_HOME is set" || echo "✗ XDG_DATA_HOME not set"
    [ -n "$XDG_CACHE_HOME" ] && echo "✓ XDG_CACHE_HOME is set" || echo "✗ XDG_CACHE_HOME not set"
}

echo "Checking development environment..."
check_directories
check_dependencies
check_permissions
check_environment
