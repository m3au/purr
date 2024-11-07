#!/bin/sh

. "${PURR_ROOT}/lib/core/common.sh"

SYSTEM_BIN_DIR="${PREFIX:-/usr/local/bin}"
SYSTEM_LIB_DIR="${PREFIX:-/usr/local/lib}/purr"
SYSTEM_CONFIG_DIR="/etc/purr"
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
USER_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/purr"
USER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/purr"

install_command() {
    info "Installing purr..."

    if [ "$(id -u)" = "0" ]; then
        install_system
    else
        install_user
    fi
}

install_system() {
    mkdir -p "$SYSTEM_BIN_DIR" "$SYSTEM_LIB_DIR" "$SYSTEM_CONFIG_DIR" || {
        error "Failed to create system directories"
        return 1
    }

    cp "$PURR_ROOT/bin/purr" "$SYSTEM_BIN_DIR/purr" || {
        error "Failed to install executable"
        return 1
    }
    chmod 755 "$SYSTEM_BIN_DIR/purr"

    cp -r "$PURR_ROOT/lib" "$SYSTEM_LIB_DIR/" || {
        error "Failed to install library files"
        return 1
    }

    cp -r "$PURR_ROOT/completion" "$SYSTEM_LIB_DIR/" || {
        error "Failed to install completion scripts"
        return 1
    }

    if [ ! -f "$SYSTEM_CONFIG_DIR/purr.conf" ]; then
        cp "$PURR_ROOT/config/purr.conf.default" "$SYSTEM_CONFIG_DIR/purr.conf" || {
            error "Failed to install system config"
            return 1
        }
        chmod 644 "$SYSTEM_CONFIG_DIR/purr.conf"
    fi

    success "System-wide installation complete"
}

install_user() {
    mkdir -p "$USER_CONFIG_DIR" "$USER_DATA_DIR/backups" "$USER_CACHE_DIR" || {
        error "Failed to create user directories"
        return 1
    }
    chmod 700 "$USER_CONFIG_DIR" "$USER_DATA_DIR" "$USER_CACHE_DIR"

    if [ ! -f "$USER_CONFIG_DIR/config" ]; then
        cp "$PURR_ROOT/config/user.conf.default" "$USER_CONFIG_DIR/config" || {
            error "Failed to install user config"
            return 1
        }
        chmod 600 "$USER_CONFIG_DIR/config"
    fi

    setup_shell_integration || {
        error "Failed to setup shell integration"
        return 1
    }

    success "User installation complete"
}

setup_shell_integration() {
    SHELL_RC="${HOME}/.$(basename "$SHELL")rc"
    if ! grep -q "# purr configuration" "$SHELL_RC" 2>/dev/null; then
        mkdir -p "$(dirname "$SHELL_RC")"
        cat > "$SHELL_RC" <<'EOF'
# purr configuration
export PURR_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
export PURR_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/purr"
export PURR_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/purr"
export PURR_SYSTEM_CONFIG="/etc/purr"
export PURR_LIB="/usr/local/lib/purr"

[ -s "$PURR_LIB/completion.sh" ] && . "$PURR_LIB/completion.sh"
EOF
    fi
    return 0
}

# TODO: Add dev install mode
# TODO: Add symlink-based installation
# TODO: Handle shell reload after installation
# TODO: Implement XDG paths
