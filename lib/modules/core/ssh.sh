#!/bin/sh
# SSH key management functionality

load_ssh_key() {
    item_name="$1"

    printf "Loading SSH key from %s...\n" "$item_name"

    # Get SSH key from 1Password using standardized field names
    key_data=$(op read "op://$PURR_VAULT/$item_name/$PURR_SSH_PRIVATE_FIELD" 2>/dev/null) || {
        printf "❌ Failed to read SSH key from 1Password\n"
        return 1
    }

    # Create temporary file for the key
    key_file=$(mktemp)
    printf "%s" "$key_data" >"$key_file"
    chmod 600 "$key_file"

    # Add key to agent
    ssh-add "$key_file" >/dev/null 2>&1 || {
        rm -f "$key_file"
        printf "❌ Failed to add SSH key to agent\n"
        return 1
    }

    # Clean up
    rm -f "$key_file"

    printf "✓ SSH key loaded\n"
}

check_ssh_status() {
    if ! pgrep ssh-agent >/dev/null; then
        printf "❌ SSH agent not running\n"
        return 1
    fi

    key_count=$(ssh-add -l 2>/dev/null | wc -l)
    if [ "$key_count" -eq 0 ]; then
        printf "❌ No SSH keys loaded\n"
        return 1
    fi

    printf "✓ SSH agent running with %s keys\n" "$key_count"
}
