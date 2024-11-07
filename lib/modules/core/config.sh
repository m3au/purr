#!/bin/sh
# Core configuration functionality

# Initialize configuration with defaults
init_config() {
    # 1Password vault settings
    PURR_VAULT="${PURR_VAULT:-purr}"

    # GPG key settings
    PURR_GPG_ITEM="${PURR_GPG_ITEM:-purr gpg}"
    PURR_GPG_KEYID_FIELD="${PURR_GPG_KEYID_FIELD:-key_id}"
    PURR_GPG_PASSWORD_FIELD="${PURR_GPG_PASSWORD_FIELD:-password}"
    PURR_GPG_PUBLIC_FIELD="${PURR_GPG_PUBLIC_FIELD:-public_key}"
    PURR_GPG_PRIVATE_FIELD="${PURR_GPG_PRIVATE_FIELD:-private_key}"

    # SSH key settings
    PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"
    PURR_SSH_PUBLIC_FIELD="${PURR_SSH_PUBLIC_FIELD:-public_key}"
    PURR_SSH_PRIVATE_FIELD="${PURR_SSH_PRIVATE_FIELD:-private_key}"

    # Load user config if exists
    if [ -f "$HOME/.purr/config" ]; then
        . "$HOME/.purr/config"
    fi

    export PURR_VAULT
    export PURR_GPG_ITEM
    export PURR_GPG_KEYID_FIELD
    export PURR_GPG_PASSWORD_FIELD
    export PURR_GPG_PUBLIC_FIELD
    export PURR_GPG_PRIVATE_FIELD
    export PURR_GITHUB_ITEM
    export PURR_SSH_PUBLIC_FIELD
    export PURR_SSH_PRIVATE_FIELD
}

# Save current configuration
save_config() {
    mkdir -p "$HOME/.purr"
    {
        printf "# purr configuration - Generated on %s\n\n" "$(date)"
        printf "# 1Password vault settings\n"
        printf "PURR_VAULT='%s'\n\n" "$PURR_VAULT"

        printf "# GPG key settings\n"
        printf "PURR_GPG_ITEM='%s'\n" "$PURR_GPG_ITEM"
        printf "PURR_GPG_KEYID_FIELD='%s'\n" "$PURR_GPG_KEYID_FIELD"
        printf "PURR_GPG_PASSWORD_FIELD='%s'\n" "$PURR_GPG_PASSWORD_FIELD"
        printf "PURR_GPG_PUBLIC_FIELD='%s'\n" "$PURR_GPG_PUBLIC_FIELD"
        printf "PURR_GPG_PRIVATE_FIELD='%s'\n\n" "$PURR_GPG_PRIVATE_FIELD"

        printf "# SSH key settings\n"
        printf "PURR_GITHUB_ITEM='%s'\n" "$PURR_GITHUB_ITEM"
        printf "PURR_SSH_PUBLIC_FIELD='%s'\n" "$PURR_SSH_PUBLIC_FIELD"
        printf "PURR_SSH_PRIVATE_FIELD='%s'\n" "$PURR_SSH_PRIVATE_FIELD"
    } >"$HOME/.purr/config"
}

# Get a configuration value
get_config() {
    config_file="$HOME/.purr/config"
    key="$1"

    # Validate config file exists and is readable
    if [ ! -f "$config_file" ]; then
        handle_error "Configuration file not found: $config_file"
        return 1
    fi
    if [ ! -r "$config_file" ]; then
        handle_error "Configuration file not readable: $config_file"
        return 1
    fi

    eval "echo \"\${$key}\""
}

# Set a configuration value
set_config() {
    config_file="$HOME/.purr/config"
    key="$1"
    value="$2"

    # Ensure config directory exists
    mkdir -p "$HOME/.purr"

    # Validate config file is writable (or can be created)
    if [ -f "$config_file" ] && [ ! -w "$config_file" ]; then
        handle_error "Configuration file not writable: $config_file"
        return 1
    fi
    if [ ! -f "$config_file" ] && [ ! -w "$HOME/.purr" ]; then
        handle_error "Configuration directory not writable: $HOME/.purr"
        return 1
    fi

    eval "$key=\"$value\""
    save_config
}

# Add this function to the existing config.sh file

validate_config() {
    errors=0

    # Check required variables
    for var in PURR_VAULT PURR_GPG_ITEM PURR_GITHUB_ITEM; do
        if [ -z "$(eval echo \$"$var")" ]; then
            printf "❌ Missing required config: %s\n" "$var"
            errors=$((errors + 1))
        fi
    done

    # Validate 1Password vault
    if ! op vault get "$PURR_VAULT" >/dev/null 2>&1; then
        printf "❌ Invalid 1Password vault: %s\n" "$PURR_VAULT"
        errors=$((errors + 1))
    fi

    # Validate GPG item exists
    if ! op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT" >/dev/null 2>&1; then
        printf "❌ GPG item not found: %s\n" "$PURR_GPG_ITEM"
        errors=$((errors + 1))
    fi

    # Validate GitHub item exists
    if ! op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT" >/dev/null 2>&1; then
        printf "❌ GitHub item not found: %s\n" "$PURR_GITHUB_ITEM"
        errors=$((errors + 1))
    fi

    # Check config file permissions
    config_file="$HOME/.purr/config"
    if [ -f "$config_file" ]; then
        if [ "$(stat -f "%Op" "$config_file" | cut -c 4-6)" != "600" ]; then
            printf "❌ Insecure config file permissions\n"
            printf "   Run: chmod 600 %s\n" "$config_file"
            errors=$((errors + 1))
        fi
    fi

    [ "$errors" -eq 0 ] && return 0 || return 1
}

# shellcheck source=/dev/null
[ -f "$HOME/.purr/config" ] && . "$HOME/.purr/config"
