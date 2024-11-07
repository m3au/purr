#!/bin/sh
# GPG key management functionality

load_gpg_key() {
    item_name="$1"

    # Get GPG key from 1Password using standardized field names
    key_data=$(op read "op://$PURR_VAULT/$item_name/$PURR_GPG_PRIVATE_FIELD" 2>/dev/null) || {
        printf "❌ Failed to read GPG key from 1Password\n"
        return 1
    }

    # Create temporary file for the key
    key_file=$(mktemp)
    printf "%s" "$key_data" >"$key_file"
    chmod 600 "$key_file"

    # Import key to GPG
    gpg --batch --import "$key_file" >/dev/null 2>&1 || {
        rm -f "$key_file"
        printf "❌ Failed to import GPG key\n"
        return 1
    }

    # Clean up
    rm -f "$key_file"

    # Get key ID for Git configuration using standardized field
    key_id=$(op item get "$item_name" --vault "$PURR_VAULT" --field "$PURR_GPG_KEY_ID_FIELD")

    if [ -n "$key_id" ]; then
        git config --global user.signingkey "$key_id"
        git config --global commit.gpgsign true
        printf "✓ Git signing configured with key %s\n" "$key_id"
    fi

    printf "✓ GPG key loaded\n"
}

check_gpg_status() {
    if ! gpg-connect-agent --quiet /bye >/dev/null 2>&1; then
        printf "❌ GPG agent not running\n"
        return 1
    fi

    key_count=$(gpg --list-secret-keys 2>/dev/null | grep -c '^sec')
    if [ "$key_count" -eq 0 ]; then
        printf "❌ No GPG keys loaded\n"
        return 1
    fi

    printf "✓ GPG agent running with %s keys\n" "$key_count"
}
