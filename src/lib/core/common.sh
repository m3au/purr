#!/bin/sh

handle_error() {
    error_msg="$1"
    error_code="${2:-1}"

    printf "❌ %s\n" "$error_msg" >&2
    return "$error_code"
}

success() {
    printf "✓ %s\n" "$1"
}

error() {
    printf "❌ %s\n" "$1"
}

info() {
    printf "➜ %s\n" "$1"
}
