#!/bin/sh

reset_command() {
    info "Resetting configuration..."

    config_dir="$HOME/.purr"
    config_file="$config_dir/config"

    info "This will reset all configuration to defaults."
    printf "Continue? [y/N] "
    read -r confirm
    case "$confirm" in
    [Yy]*)
        backup_command

        rm -f "$config_file"

        mkdir -p "$config_dir"
        {
            printf "PURR_VAULT='purr'\n"
            printf "PURR_GPG_ITEM='purr gpg'\n"
            printf "PURR_GITHUB_ITEM='GitHub'\n"
        } >"$config_file"

        success "Configuration reset to defaults"
        ;;
    *)
        info "Reset cancelled"
        return 1
        ;;
    esac
}
