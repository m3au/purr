#!/bin/sh

. "${PURR_ROOT}/lib/core/common.sh"

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
backup_dir="${XDG_DATA_HOME:-$HOME/.local/share}/purr/backups"

reset_config() {
    timestamp=""
    backup_path=""

    # Backup existing config if it exists
    if [ -d "$config_dir" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_path="$backup_dir/config_$timestamp"
        mkdir -p "$backup_dir"
        cp -r "$config_dir" "$backup_path"
    fi

    # Remove existing config
    rm -rf "$config_dir"

    # Create fresh config directory
    mkdir -p "$config_dir"

    return 0
}

# Execute if script is run directly
if [ "${0##*/}" = "reset.sh" ]; then
    reset_config
fi
