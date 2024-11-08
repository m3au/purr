#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"
. "${PURR_ROOT}/lib/modules/core/color.sh"

check_git_status() {
    if ! command -v git >/dev/null 2>&1; then
        error "Git not installed"
        return 1
    fi

    errors=0

    if [ -z "$(git config --global user.name)" ]; then
        error "Git user.name not configured"
        errors=$((errors + 1))
    fi

    if [ -z "$(git config --global user.email)" ]; then
        error "Git user.email not configured"
        errors=$((errors + 1))
    fi

    signing_key=$(git config --global user.signingkey)
    if [ -n "$signing_key" ]; then
        display_key=$(printf '%s' "$signing_key" | sed 's/.\{4\}\(.*\).\{4\}/****\1****/')
        success "Git signing configured with key: $display_key"
    else
        error "Git signing key not configured"
        errors=$((errors + 1))
    fi

    [ "$errors" -eq 0 ] && return 0 || return 1
}
