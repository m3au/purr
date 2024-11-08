#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"
. "${PURR_ROOT}/lib/modules/core/color.sh"

check_1password_status() {
    if ! command -v op >/dev/null 2>&1; then
        error "1Password CLI not installed"
        return 1
    fi

    if ! op whoami >/dev/null 2>&1; then
        error "Not signed in to 1Password"
        return 1
    fi

    success "Connected to 1Password"
    return 0
}

check_existing_setup() {
    has_existing=false
    details=""

    info "Checking existing configuration..."

    if [ -n "$SSH_AUTH_SOCK" ]; then
        has_existing=true
        details="${details}ᓚᘏᗢ SSH agent is connected\n"
        if ssh-add -l 2>/dev/null | grep -q "The agent has no identities."; then
            details="${details}    ✗ No keys loaded\n"
        else
            details="${details}    ✓ Keys loaded\n"
        fi
    fi

    if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "sec"; then
        has_existing=true
        details="${details}GPG keys are present\n"
        key_count=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -c "^sec")
        details="${details}    ✓ ${key_count} key(s) loaded\n"
    fi

    signing_key=$(git config --global user.signingkey)
    commit_sign=$(git config --global commit.gpgsign)
    if [ -n "$signing_key" ] || [ "$commit_sign" = "true" ]; then
        has_existing=true
        details="${details}Git signing is configured\n"
        [ -n "$signing_key" ] && details="${details}    ✓ Signing key is set\n"
        [ "$commit_sign" = "true" ] && details="${details}    ✓ Commit signing is enabled\n"
    fi

    if [ "$has_existing" = "true" ]; then
        colorize "✨ Existing configuration found"
        printf '\nCurrent setup:\n'
        printf '%b' "${details}"
        printf 'Override existing configuration? [y/N] '
        read -r reply
        case "$reply" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
        esac
    fi

    return 0
}

# TODO: Implement 1Password CLI detection
# TODO: Add authentication flow validation
# TODO: Add item access validation
