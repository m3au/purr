#!/bin/sh

. "${PURR_ROOT}/lib/core/common.sh"

uninstall_command() {
    info "Uninstalling purr..."

    lock_command

    if [ "$(id -u)" = "0" ]; then
        uninstall_system
    else
        uninstall_user
    fi
}

uninstall_system() {
    if [ -f "$SYSTEM_BIN_DIR/purr" ]; then
        rm "$SYSTEM_BIN_DIR/purr" || {
            error "Failed to remove executable"
            return 1
        }
        success "Removed executable"
    fi

    if [ -d "$SYSTEM_LIB_DIR" ]; then
        rm -rf "$SYSTEM_LIB_DIR" || {
            error "Failed to remove library files"
            return 1
        }
        success "Removed library files"
    fi

    if [ -d "$SYSTEM_CONFIG_DIR" ]; then
        rm -rf "$SYSTEM_CONFIG_DIR" || {
            error "Failed to remove system config"
            return 1
        }
        success "Removed system configuration"
    fi

    success "System-wide uninstallation complete"
}

uninstall_user() {
    SHELL_RC="${HOME}/.$(basename "$SHELL")rc"
    if [ -f "$SHELL_RC" ]; then
        sed -i.bak '/# purr configuration/,/completion.sh/d' "$SHELL_RC"
        rm -f "${SHELL_RC}.bak"
        success "Removed shell configuration"
    fi

    info "Remove user data? [y/N] "
    read -r remove_data
    case "$remove_data" in
    [Yy]*)
        rm -rf "$USER_CONFIG_DIR" "$USER_DATA_DIR" "$USER_CACHE_DIR"
        success "Removed user data"
        ;;
    *)
        info "User data preserved"
        ;;
    esac

    success "User uninstallation complete"
    info "Please restart your shell or run: source $SHELL_RC"
}
