#!/bin/sh

lock_command() {
    info "Locking keys..."

    errors=0

    if [ -n "$SSH_AUTH_SOCK" ]; then
        if ! ssh-add -D >/dev/null 2>&1; then
            error "Failed to unload SSH keys"
            errors=$((errors + 1))
        else
            success "SSH keys unloaded"
        fi
    fi

    if pgrep ssh-agent >/dev/null; then
        if ! ssh-agent -k >/dev/null 2>&1; then
            error "Failed to stop SSH agent"
            errors=$((errors + 1))
        else
            success "SSH agent stopped"
        fi
    fi

    if gpg-connect-agent --quiet /bye >/dev/null 2>&1; then
        if ! gpgconf --kill gpg-agent >/dev/null 2>&1; then
            error "Failed to stop GPG agent"
            errors=$((errors + 1))
        else
            success "GPG agent stopped"
        fi
    fi

    if ! git config --global --unset user.signingkey 2>/dev/null; then
        error "Failed to unset Git signing key"
        errors=$((errors + 1))
    fi
    if ! git config --global --unset commit.gpgsign 2>/dev/null; then
        error "Failed to disable Git signing"
        errors=$((errors + 1))
    else
        success "Git signing disabled"
    fi

    if command -v op >/dev/null 2>&1; then
        if ! op signout --all >/dev/null 2>&1; then
            error "Failed to lock 1Password"
            errors=$((errors + 1))
        else
            success "1Password locked"
        fi
    fi

    if [ "$errors" -gt 0 ]; then
        error "Completed with $errors errors"
        return 1
    fi

    success "All keys unloaded and agents stopped"
    return 0
}
