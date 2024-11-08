#!/bin/bash

# Source core functionality
. "${PURR_ROOT}/lib/core/common.sh"

# Set strict mode
set -euo pipefail

# Default environment variables
PURR_ROOT="${PURR_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/purr}"
PURR_LIB="${PURR_LIB:-$PURR_ROOT/lib}"
PURR_BIN="${PURR_BIN:-$PURR_ROOT/bin}"

# Logging functions
log() {
    _level=$1; shift
    _msg="$*"
    _timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$_level" in
        INFO)  printf "%s [%s] %s\n" "$_timestamp" "$_level" "$_msg" ;;
        WARN)  printf "%s [%s] %s\n" "$_timestamp" "$_level" "$_msg" >&2 ;;
        ERROR) printf "%s [%s] %s\n" "$_timestamp" "$_level" "$_msg" >&2 ;;
    esac
}

# File operations
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        chmod 755 "$dir"
    fi
}

ensure_file() {
    local file="$1"
    local mode="${2:-644}"
    if [ ! -f "$file" ]; then
        touch "$file"
        chmod "$mode" "$file"
    fi
}
