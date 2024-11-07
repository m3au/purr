#!/bin/sh

config_command() {
    case "$1" in
    get)
        shift
        if [ -z "$1" ]; then
            while IFS= read -r key; do
                case "$key" in
                PURR_*)
                    value=$(get_config "$key")
                    printf "%s='%s'\n" "$key" "$value"
                    ;;
                esac
            done <<EOF
$(set | grep '^PURR_' | cut -d= -f1)
EOF
            return 0
        fi
        value=$(get_config "$1")
        if [ -z "$value" ]; then
            handle_error "Configuration key not found: $1"
            return 1
        fi
        printf "%s\n" "$value"
        ;;
    set)
        shift
        if [ -z "$1" ] || [ -z "$2" ]; then
            handle_error "Usage: purr config set <key> <value>"
            return 1
        fi
        set_config "$1" "$2"
        printf "✓ Set %s to '%s'\n" "$1" "$2"
        ;;
    list)
        printf "➜ Current configuration:\n\n"

        while IFS= read -r key; do
            case "$key" in
            PURR_*)
                value=$(get_config "$key")
                printf "%s: %s\n" "$key" "$value"
                ;;
            esac
        done <<EOF
$(set | grep '^PURR_' | cut -d= -f1)
EOF
        ;;
    *)
        handle_error "Usage: purr config <get|set|list> [key] [value]"
        return 1
        ;;
    esac

    return 0
}
