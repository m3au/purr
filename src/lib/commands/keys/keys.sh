#!/bin/sh

keys_command() {
    case "$1" in
    list)
        shift
        if ! list_keys; then
            error "Failed to list keys"
            return 1
        fi
        ;;
    load)
        shift
        if [ -z "$1" ]; then
            error "Usage: purr keys load <key-name>"
            return 1
        fi
        if ! load_key "$1"; then
            error "Failed to load key: $1"
            return 1
        fi
        ;;
    unload)
        shift
        if [ -z "$1" ]; then
            error "Usage: purr keys unload <key-name>"
            return 1
        fi
        if ! unload_key "$1"; then
            error "Failed to unload key: $1"
            return 1
        fi
        ;;
    *)
        error "Usage: purr keys <list|load|unload> [key-name]"
        return 1
        ;;
    esac

    return 0
}

list_keys() {
    info "SSH Keys:"
    ssh-add -l || true

    info "GPG Keys:"
    gpg --list-secret-keys --keyid-format LONG || true

    info "Git Signing Key:"
    git config --get user.signingkey || echo "No signing key configured"
}

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
        error "Unknown key type: $key_name"
        return 1
        ;;
    esac
}

unload_key() {
    key_name="$1"

    case "$key_name" in
    *".ssh"*)
        if ! ssh-add -d "$key_name" >/dev/null 2>&1; then
            error "Failed to unload SSH key: $key_name"
            return 1
        fi
        ;;
    *".gpg"*)
        if ! gpg --delete-secret-keys "$key_name" >/dev/null 2>&1; then
            error "Failed to unload GPG key: $key_name"
            return 1
        fi
        ;;
    *)
        error "Unknown key type: $key_name"
        return 1
        ;;
    esac

    success "Unloaded key: $key_name"
}
