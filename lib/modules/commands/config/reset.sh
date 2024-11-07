#!/bin/sh
# Reset configuration functionality

reset_command() {
    printf "➜ Resetting configuration...\n"

    config_dir="$HOME/.purr"
    config_file="$config_dir/config"

    # Confirm reset
    printf "This will reset all configuration to defaults.\n"
    printf "Continue? [y/N] "
    read -r confirm
    case "$confirm" in
    [Yy]*)
        # Create backup before reset
        backup_command

        # Remove existing config
        rm -f "$config_file"

        # Create default configuration
        mkdir -p "$config_dir"
        {
            printf "PURR_VAULT='purr'\n"
            printf "PURR_GPG_ITEM='purr gpg'\n"
            printf "PURR_GITHUB_ITEM='GitHub'\n"
        } >"$config_file"

        printf "✓ Configuration reset to defaults\n"
        ;;
    *)
        printf "Reset cancelled\n"
        return 1
        ;;
    esac
}
