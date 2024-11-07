#!/bin/sh
# Git-related utilities

# Source dependencies using same pattern as main purr script
. "$(dirname "$0")/common.sh"
. "$(dirname "$0")/color.sh"

check_git_status() {
    if ! command -v git >/dev/null 2>&1; then
        error "Git not installed"
        return 1
    fi

    errors=0

    # Check Git user configuration
    if [ -z "$(git config --global user.name)" ]; then
        error "Git user.name not configured"
        errors=$((errors + 1))
    fi

    if [ -z "$(git config --global user.email)" ]; then
        error "Git user.email not configured"
        errors=$((errors + 1))
    fi

    # Check Git signing configuration
    signing_key=$(git config --global user.signingkey)
    if [ -n "$signing_key" ]; then
        # Inline obfuscation using sed
        display_key=$(printf '%s' "$signing_key" | sed 's/.\{4\}\(.*\).\{4\}/****\1****/')
        success "Git signing configured with key: $display_key"
    else
        error "Git signing key not configured"
        errors=$((errors + 1))
    fi

    [ "$errors" -eq 0 ] && return 0 || return 1
}
