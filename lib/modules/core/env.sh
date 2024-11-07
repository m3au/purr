#!/bin/sh
# Environment validation utilities

# shellcheck source=lib/modules/core/common.sh
. "$(dirname "$0")/common.sh"

validate_env() {
    if [ -z "$PURR_HOME" ]; then
        handle_error "PURR_HOME environment variable not set"
        return 1
    fi

    if [ ! -d "$PURR_HOME" ]; then
        handle_error "PURR_HOME directory does not exist: $PURR_HOME"
        return 1
    fi

    success "Environment validated"
    return 0
}

check_required_commands() {
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            handle_error "Required command not found: $cmd"
            return 1
        fi
    done
    success "All required commands found"
    return 0
}
