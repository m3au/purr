#!/bin/sh

status_command() {
    if [ "${SOURCING:-0}" = "1" ]; then
        return 0
    fi

    if ! validate_env; then
        return 1
    fi

    if ! check_required_commands ssh-add gpg git op; then
        return 1
    fi

    case "$1" in
    --keys | -k)
        if ! list_keys; then
            error "Failed to list keys"
            return 1
        fi
        ;;
    --debug | -d)
        if ! debug_status; then
            error "Failed to get debug status"
            return 1
        fi
        ;;
    --check | -c)
        if ! check_keys; then
            error "Failed to check keys"
            return 1
        fi
        ;;
    "")
        info "Current Status:"
        errors=0

        if ! check_1password_status; then
            errors=$((errors + 1))
            info "Run 'op signin' to connect to 1Password"
        fi

        if ! check_ssh_status; then
            errors=$((errors + 1))
            info "Run 'purr' to load SSH keys"
        fi

        if ! check_gpg_status; then
            errors=$((errors + 1))
            info "Run 'purr' to load GPG keys"
        fi

        if ! check_git_status; then
            errors=$((errors + 1))
            info "Run 'purr' to configure Git signing"
        fi

        if [ "$errors" -gt 0 ]; then
            error "Completed with $errors error(s)"
            return 1
        fi

        success "All systems operational"
        ;;
    *)
        error "Usage: purr status [--keys|-k] [--debug|-d] [--check|-c]"
        return 1
        ;;
    esac

    return 0
}
