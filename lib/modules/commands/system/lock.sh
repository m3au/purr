#!/bin/sh
# Lock command functionality

lock_command() {
    printf "➜ Locking keys...\n"

    errors=0

    # Unload SSH keys
    if [ -n "$SSH_AUTH_SOCK" ]; then
        if ! ssh-add -D >/dev/null 2>&1; then
            handle_error "Failed to unload SSH keys"
            errors=$((errors + 1))
        else
            printf "✓ SSH keys unloaded\n"
        fi
    fi

    # Kill SSH agent
    if pgrep ssh-agent >/dev/null; then
        if ! ssh-agent -k >/dev/null 2>&1; then
            handle_error "Failed to stop SSH agent"
            errors=$((errors + 1))
        else
            printf "✓ SSH agent stopped\n"
        fi
    fi

    # Kill GPG agent
    if gpg-connect-agent --quiet /bye >/dev/null 2>&1; then
        if ! gpgconf --kill gpg-agent >/dev/null 2>&1; then
            handle_error "Failed to stop GPG agent"
            errors=$((errors + 1))
        else
            printf "✓ GPG agent stopped\n"
        fi
    fi

    # Disable Git signing
    if ! git config --global --unset user.signingkey 2>/dev/null; then
        handle_error "Failed to unset Git signing key"
        errors=$((errors + 1))
    fi
    if ! git config --global --unset commit.gpgsign 2>/dev/null; then
        handle_error "Failed to disable Git signing"
        errors=$((errors + 1))
    else
        printf "✓ Git signing disabled\n"
    fi

    # Lock 1Password if available
    if command -v op >/dev/null 2>&1; then
        if ! op signout --all >/dev/null 2>&1; then
            handle_error "Failed to lock 1Password"
            errors=$((errors + 1))
        else
            printf "✓ 1Password locked\n"
        fi
    fi

    if [ "$errors" -gt 0 ]; then
        handle_error "Completed with $errors errors"
        return 1
    fi

    printf "\n✨ All keys unloaded and agents stopped\n"
    return 0
}
