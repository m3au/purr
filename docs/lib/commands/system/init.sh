#!/bin/sh

. "${PURR_LIB}/core/common.sh"

USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
USER_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/purr"
USER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/purr"
COMPLETION_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"

install_command() {
    info "Installing purr..."

    # Create XDG directories
    mkdir -p "$USER_CONFIG_DIR" "$USER_DATA_DIR/backups" "$USER_CACHE_DIR" || {
        error "Failed to create user directories"
        return 1
    }
    chmod 700 "$USER_CONFIG_DIR" "$USER_DATA_DIR" "$USER_CACHE_DIR"

    # Install completion script
    mkdir -p "$COMPLETION_DIR" || {
        error "Failed to create completion directory"
        return 1
    }
    cp "$PURR_ROOT/src/completion/completion.zsh" "$COMPLETION_DIR/_purr" || {
        error "Failed to install completion script"
        return 1
    }
    chmod 644 "$COMPLETION_DIR/_purr"

    setup_shell_integration || {
        error "Failed to setup shell integration"
        return 1
    }

    success "Installation complete"
}

setup_shell_integration() {
    SHELL_RC="${HOME}/.$(basename "$SHELL")rc"
    if ! grep -q "# purr configuration" "$SHELL_RC" 2>/dev/null; then
        cat >> "$SHELL_RC" <<'EOF'

# purr configuration
export PURR_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
export PURR_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/purr"
export PURR_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/purr"

# Add completion directory to fpath if not already included
fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions" $fpath)
EOF
    fi
    return 0
}
