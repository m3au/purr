#!/bin/sh
# Configuration backup functionality

backup_command() {
    backup_dir="$HOME/.purr/backups"
    backup_file="$backup_dir/purr-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    config_dir="$HOME/.purr"

    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"

    printf "➜ Creating backup...\n"

    # Create temporary directory for filtered files
    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT

    # Copy config files, excluding sensitive data
    if [ -d "$config_dir" ]; then
        cp -r "$config_dir" "$temp_dir/"

        # Remove sensitive files and data
        find "$temp_dir" -type f -name "*.key" -delete
        find "$temp_dir" -type f -name "*.gpg" -delete
        find "$temp_dir" -type f -name "*.secret" -delete

        # Remove sensitive lines from config
        if [ -f "$temp_dir/.purr/config" ]; then
            sed -i '/\(TOKEN\|SECRET\|PASSWORD\|KEY\)/d' "$temp_dir/.purr/config"
        fi
    fi

    # Create backup archive
    tar -czf "$backup_file" -C "$temp_dir" . >/dev/null 2>&1 || {
        printf "❌ Failed to create backup\n"
        return 1
    }

    printf "✓ Backup created: %s\n" "$backup_file"
    printf "Note: Sensitive data was excluded from the backup\n"
}
