#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"

load_gpg_key() {
    item_name="$1"

    key_data=$(op read "op://$PURR_VAULT/$item_name/$PURR_GPG_PRIVATE_FIELD" 2>/dev/null) || {
        error "Failed to read GPG key from 1Password"
        return 1
    }

    key_file=$(mktemp)
    printf "%s" "$key_data" >"$key_file"
    chmod 600 "$key_file"

    gpg --batch --import "$key_file" >/dev/null 2>&1 || {
        rm -f "$key_file"
        error "Failed to import GPG key"
        return 1
    }

    rm -f "$key_file"

    key_id=$(op item get "$item_name" --vault "$PURR_VAULT" --field "$PURR_GPG_KEY_ID_FIELD")

    if [ -n "$key_id" ]; then
        git config --global user.signingkey "$key_id"
        git config --global commit.gpgsign true
        success "Git signing configured with key $key_id"
    fi

    success "GPG key loaded"
}

check_gpg_status() {
    if ! gpg-connect-agent --quiet /bye >/dev/null 2>&1; then
        error "GPG agent not running"
        return 1
    fi

    key_count=$(gpg --list-secret-keys 2>/dev/null | grep -c '^sec')
    if [ "$key_count" -eq 0 ]; then
        error "No GPG keys loaded"
        return 1
    fi

    success "GPG agent running with $key_count keys"
}

# TODO: Implement agent lifecycle management
# TODO: Add key validation
# TODO: Add Git signing setup validation
