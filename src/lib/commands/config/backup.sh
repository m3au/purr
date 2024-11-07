#!/bin/sh

backup_command() {
    backup_dir="$USER_DATA_DIR/backups"
    backup_file="$backup_dir/purr-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    mkdir -p "$backup_dir"

    info "Creating backup..."

    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT

    if [ -d "$USER_CONFIG_DIR" ]; then
        cp -r "$USER_CONFIG_DIR" "$temp_dir/"
    fi

    if [ -d "$USER_DATA_DIR" ]; then
        cp -r "$USER_DATA_DIR" "$temp_dir/"
    fi

    find "$temp_dir" -type f -name "*.key" -delete
    find "$temp_dir" -type f -name "*.gpg" -delete
    find "$temp_dir" -type f -name "*.secret" -delete

    if [ -f "$temp_dir/config" ]; then
        sed -i '/\(TOKEN\|SECRET\|PASSWORD\|KEY\)/d' "$temp_dir/config"
    fi

    tar -czf "$backup_file" -C "$temp_dir" . >/dev/null 2>&1 || {
        error "Failed to create backup"
        return 1
    }

    success "Backup created: $backup_file"
    info "Note: Sensitive data was excluded from the backup"
}
