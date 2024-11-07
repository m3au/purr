#!/bin/sh
# Install command functionality

install_command() {
    printf "➜ Installing purr...\n"

    # Create system installation directory
    install_dir="${PREFIX:-/usr/local}/bin"
    if [ ! -d "$install_dir" ]; then
        printf "Creating installation directory...\n"
        mkdir -p "$install_dir" || {
            handle_error "Failed to create installation directory"
            return 1
        }
    fi

    # Create user installation directory structure
    INSTALL_DIR="${HOME}/.purr"
    mkdir -p "${INSTALL_DIR}/lib/modules/core" \
        "${INSTALL_DIR}/lib/modules/commands" \
        "${INSTALL_DIR}/scripts" \
        "${INSTALL_DIR}/backup" || {
        handle_error "Failed to create installation directories"
        return 1
    }
    chmod 700 "${INSTALL_DIR}" "${INSTALL_DIR}/backup"

    # Copy files preserving directory structure
    printf "Copying files...\n"
    cp -r "$PURR_ROOT/lib/modules/core/"* "${INSTALL_DIR}/lib/modules/core/" || {
        handle_error "Failed to copy core modules"
        return 1
    }
    cp -r "$PURR_ROOT/lib/modules/commands/"* "${INSTALL_DIR}/lib/modules/commands/" || {
        handle_error "Failed to copy command modules"
        return 1
    }
    cp "$PURR_ROOT/lib/purr" "${INSTALL_DIR}/lib/" || {
        handle_error "Failed to copy main script"
        return 1
    }
    cp "$PURR_ROOT/scripts/completion.sh" "${INSTALL_DIR}/scripts/" || {
        handle_error "Failed to copy completion script"
        return 1
    }

    # Install main executable
    printf "Installing purr executable...\n"
    cp "$PURR_ROOT/bin/purr" "$install_dir/purr" || {
        handle_error "Failed to install executable"
        return 1
    }
    chmod 755 "$install_dir/purr"

    # Generate man page
    printf "Generating documentation...\n"
    mkdir -p "${INSTALL_DIR}/man/man1"
    if command -v md2man-roff >/dev/null 2>&1; then
        md2man-roff "$PURR_ROOT/docs/purr.1.md" >"${INSTALL_DIR}/man/man1/purr.1" || {
            handle_error "Failed to generate man page"
            return 1
        }
    fi

    # Add to shell config if not already present
    SHELL_RC="${HOME}/.$(basename "$SHELL")rc"
    if ! grep -q "PURR_HOME.*/.purr" "$SHELL_RC"; then
        printf "Updating shell configuration...\n"
        cat <<EOF >>"$SHELL_RC"

# purr - Key management utility
export PURR_HOME="\${HOME}/.purr"
export PURR_LIB="\${PURR_HOME}/lib"
[ -s "\$PURR_LIB/purr" ] && . "\$PURR_LIB/purr"
[ -s "\$PURR_HOME/scripts/completion.sh" ] && . "\$PURR_HOME/scripts/completion.sh"
EOF
    fi

    # Create default configuration if none exists
    if [ ! -f "$INSTALL_DIR/config" ]; then
        printf "\n➜ No configuration found. Running setup wizard...\n\n"
        wizard_command
    fi

    printf "\n✓ Installation complete!\n"
    printf "Please restart your shell or run: source %s\n" "$SHELL_RC"
    return 0
}
