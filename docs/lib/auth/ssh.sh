#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"

load_ssh_key() {
    item_name="$1"

    info "Loading SSH key from $item_name..."

    key_data=$(op read "op://$PURR_VAULT/$item_name/$PURR_SSH_PRIVATE_FIELD" 2>/dev/null) || {
        error "Failed to read SSH key from 1Password"
        return 1
    }

    key_file=$(mktemp)
    printf "%s" "$key_data" >"$key_file"
    chmod 600 "$key_file"

    ssh-add "$key_file" >/dev/null 2>&1 || {
        rm -f "$key_file"
        error "Failed to add SSH key to agent"
        return 1
    }

    rm -f "$key_file"

    success "SSH key loaded"
}

check_ssh_status() {
    if ! pgrep ssh-agent >/dev/null; then
        error "SSH agent not running"
        return 1
    fi

    key_count=$(ssh-add -l 2>/dev/null | wc -l)
    if [ "$key_count" -eq 0 ]; then
        error "No SSH keys loaded"
        return 1
    fi

    success "SSH agent running with $key_count keys"
}

# TODO: Implement agent lifecycle management
# TODO: Add key loading validation
# TODO: Add secure key unloading
