#!/bin/sh
# Status checking functionality

status_command() {
    # Skip status check if we're just sourcing the file
    if [ "${SOURCING:-0}" = "1" ]; then
        return 0
    fi

    # Validate environment first
    if ! validate_env; then
        return 1
    fi

    # Check required commands
    if ! check_required_commands ssh-add gpg git op; then
        return 1
    fi

    # Parse subcommands and options
    case "$1" in
    --keys | -k)
        if ! list_keys; then
            handle_error "Failed to list keys"
            return 1
        fi
        ;;
    --debug | -d)
        if ! debug_status; then
            handle_error "Failed to get debug status"
            return 1
        fi
        ;;
    --check | -c)
        if ! check_keys; then
            handle_error "Failed to check keys"
            return 1
        fi
        ;;
    "")
        # Default behavior - show all status
        printf '➜ Current Status:\n\n'
        errors=0

        # Check 1Password status without failing the whole command
        if ! check_1password_status; then
            errors=$((errors + 1))
            printf "ℹ️  Run 'op signin' to connect to 1Password\n\n"
        fi

        # Check SSH status
        if ! check_ssh_status; then
            errors=$((errors + 1))
            printf "ℹ️  Run 'purr' to load SSH keys\n\n"
        fi

        # Check GPG status
        if ! check_gpg_status; then
            errors=$((errors + 1))
            printf "ℹ️  Run 'purr' to load GPG keys\n\n"
        fi

        # Check Git status
        if ! check_git_status; then
            errors=$((errors + 1))
            printf "ℹ️  Run 'purr' to configure Git signing\n\n"
        fi

        if [ "$errors" -gt 0 ]; then
            printf "❌ Completed with %s error(s)\n" "$errors"
            return 1
        fi

        printf "✨ All systems operational\n"
        ;;
    *)
        printf "Usage: purr status [--keys|-k] [--debug|-d] [--check|-c]\n"
        return 1
        ;;
    esac

    return 0
}
