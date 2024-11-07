#!/bin/sh
# Key management functionality

keys_command() {
    case "$1" in
    list)
        shift
        if ! list_keys; then
            handle_error "Failed to list keys"
            return 1
        fi
        ;;
    load)
        shift
        if [ -z "$1" ]; then
            handle_error "Usage: purr keys load <key-name>"
            return 1
        fi
        if ! load_key "$1"; then
            handle_error "Failed to load key: $1"
            return 1
        fi
        ;;
    unload)
        shift
        if [ -z "$1" ]; then
            handle_error "Usage: purr keys unload <key-name>"
            return 1
        fi
        if ! unload_key "$1"; then
            handle_error "Failed to unload key: $1"
            return 1
        fi
        ;;
    *)
        handle_error "Usage: purr keys <list|load|unload> [key-name]"
        return 1
        ;;
    esac

    return 0
}

# List all loaded keys
list_keys() {
    printf "➜ SSH Keys:\n"
    ssh-add -l || true

    printf "\n➜ GPG Keys:\n"
    gpg --list-secret-keys --keyid-format LONG || true

    printf "\n➜ Git Signing Key:\n"
    git config --get user.signingkey || echo "No signing key configured"
}

# Load a specific key
load_key() {
    key_name="$1"

    case "$key_name" in
    *".ssh"*)
        load_ssh_key "$key_name"
        ;;
    *".gpg"*)
        load_gpg_key "$key_name"
        ;;
    *)
        handle_error "Unknown key type: $key_name"
        return 1
        ;;
    esac
}

# Unload a specific key
unload_key() {
    key_name="$1"

    case "$key_name" in
    *".ssh"*)
        if ! ssh-add -d "$key_name" >/dev/null 2>&1; then
            handle_error "Failed to unload SSH key: $key_name"
            return 1
        fi
        ;;
    *".gpg"*)
        if ! gpg --delete-secret-keys "$key_name" >/dev/null 2>&1; then
            handle_error "Failed to unload GPG key: $key_name"
            return 1
        fi
        ;;
    *)
        handle_error "Unknown key type: $key_name"
        return 1
        ;;
    esac

    printf "✓ Unloaded key: %s\n" "$key_name"
}
