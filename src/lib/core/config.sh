#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"

init_config() {
    PURR_VAULT="${PURR_VAULT:-purr}"
    PURR_GPG_ITEM="${PURR_GPG_ITEM:-purr gpg}"
    PURR_GPG_KEYID_FIELD="${PURR_GPG_KEYID_FIELD:-key_id}"
    PURR_GPG_PASSWORD_FIELD="${PURR_GPG_PASSWORD_FIELD:-password}"
    PURR_GPG_PUBLIC_FIELD="${PURR_GPG_PUBLIC_FIELD:-public_key}"
    PURR_GPG_PRIVATE_FIELD="${PURR_GPG_PRIVATE_FIELD:-private_key}"
    PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"
    PURR_SSH_PUBLIC_FIELD="${PURR_SSH_PUBLIC_FIELD:-public_key}"
    PURR_SSH_PRIVATE_FIELD="${PURR_SSH_PRIVATE_FIELD:-private_key}"

    if [ -f "$HOME/.purr/config" ]; then
        . "$HOME/.purr/config"
    fi

    export PURR_VAULT PURR_GPG_ITEM PURR_GPG_KEYID_FIELD PURR_GPG_PASSWORD_FIELD
    export PURR_GPG_PUBLIC_FIELD PURR_GPG_PRIVATE_FIELD PURR_GITHUB_ITEM
    export PURR_SSH_PUBLIC_FIELD PURR_SSH_PRIVATE_FIELD
}

save_config() {
    mkdir -p "$HOME/.purr"
    {
        printf "# purr configuration - Generated on %s\n\n" "$(date)"
        printf "PURR_VAULT='%s'\n\n" "$PURR_VAULT"
        printf "PURR_GPG_ITEM='%s'\n" "$PURR_GPG_ITEM"
        printf "PURR_GPG_KEYID_FIELD='%s'\n" "$PURR_GPG_KEYID_FIELD"
        printf "PURR_GPG_PASSWORD_FIELD='%s'\n" "$PURR_GPG_PASSWORD_FIELD"
        printf "PURR_GPG_PUBLIC_FIELD='%s'\n" "$PURR_GPG_PUBLIC_FIELD"
        printf "PURR_GPG_PRIVATE_FIELD='%s'\n\n" "$PURR_GPG_PRIVATE_FIELD"
        printf "PURR_GITHUB_ITEM='%s'\n" "$PURR_GITHUB_ITEM"
        printf "PURR_SSH_PUBLIC_FIELD='%s'\n" "$PURR_SSH_PUBLIC_FIELD"
        printf "PURR_SSH_PRIVATE_FIELD='%s'\n" "$PURR_SSH_PRIVATE_FIELD"
    } >"$HOME/.purr/config"
}

get_config() {
    config_file="$HOME/.purr/config"
    key="$1"

    if [ ! -f "$config_file" ]; then
        error "Configuration file not found: $config_file"
        return 1
    fi
    if [ ! -r "$config_file" ]; then
        error "Configuration file not readable: $config_file"
        return 1
    fi

    eval "echo \"\${$key}\""
}

set_config() {
    config_file="$HOME/.purr/config"
    key="$1"
    value="$2"

    mkdir -p "$HOME/.purr"

    if [ -f "$config_file" ] && [ ! -w "$config_file" ]; then
        error "Configuration file not writable: $config_file"
        return 1
    fi
    if [ ! -f "$config_file" ] && [ ! -w "$HOME/.purr" ]; then
        error "Configuration directory not writable: $HOME/.purr"
        return 1
    fi

    eval "$key=\"$value\""
    save_config
}

validate_config() {
    errors=0

    for var in PURR_VAULT PURR_GPG_ITEM PURR_GITHUB_ITEM; do
        if [ -z "$(eval echo \$"$var")" ]; then
            error "Missing required config: $var"
            errors=$((errors + 1))
        fi
    done

    if ! op vault get "$PURR_VAULT" >/dev/null 2>&1; then
        error "Invalid 1Password vault: $PURR_VAULT"
        errors=$((errors + 1))
    fi

    if ! op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT" >/dev/null 2>&1; then
        error "GPG item not found: $PURR_GPG_ITEM"
        errors=$((errors + 1))
    fi

    if ! op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT" >/dev/null 2>&1; then
        error "GitHub item not found: $PURR_GITHUB_ITEM"
        errors=$((errors + 1))
    fi

    config_file="$HOME/.purr/config"
    if [ -f "$config_file" ]; then
        if [ "$(stat -f "%Op" "$config_file" | cut -c 4-6)" != "600" ]; then
            error "Insecure config file permissions"
            info "Run: chmod 600 $config_file"
            errors=$((errors + 1))
        fi
    fi

    [ "$errors" -eq 0 ] && return 0 || return 1
}

[ -f "$HOME/.purr/config" ] && . "$HOME/.purr/config"

# TODO: Implement config file load order: default → system → user
# TODO: Add config validation
# TODO: Add migration from ~/.purr
# TODO: Create default config files
