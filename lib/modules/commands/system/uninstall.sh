#!/bin/sh
# Uninstall command functionality

uninstall_command() {
    printf "➜ Uninstalling purr...\n"

    # Lock everything first
    lock_command

    # Remove executable
    install_dir="${PREFIX:-/usr/local}/bin"
    if [ -f "$install_dir/purr" ]; then
        rm "$install_dir/purr" || {
            printf "❌ Failed to remove executable\n"
            return 1
        }
        printf "✓ Removed executable\n"
    fi

    # Remove shell configuration
    SHELL_RC="${HOME}/.$(basename "$SHELL")rc"
    if [ -f "$SHELL_RC" ]; then
        sed -i.bak '/# purr - Key management utility/,+3d' "$SHELL_RC"
        rm -f "${SHELL_RC}.bak" # Remove the backup file created by sed
        printf "✓ Removed shell configuration\n"
    fi

    # Optionally remove config and backups
    printf "Remove configuration and backups? [y/N] "
    read -r remove_config
    case "$remove_config" in
    [Yy]*)
        rm -rf "$HOME/.purr"
        printf "✓ Removed configuration and backups\n"
        ;;
    esac

    printf "\n✓ Uninstallation complete!\n"
    printf "Please restart your shell or run: source %s\n" "$SHELL_RC"
}
