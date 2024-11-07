#!/bin/sh

doctor_command() {
    info "Running system diagnostics..."

    errors=0

    info "Checking installation:"
    install_dir="${PREFIX:-/usr/local}/bin"
    if [ ! -f "$install_dir/purr" ]; then
        error "purr not found in $install_dir"
        info "Run 'purr install' to fix"
        errors=$((errors + 1))
    else
        success "Installation verified"
    fi

    info "Checking configuration:"
    if ! validate_config; then
        errors=$((errors + 1))
    fi

    info "Checking dependencies:"
    for dep in op ssh-agent gpg git; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error "Missing dependency: $dep"
            errors=$((errors + 1))
        else
            success "Found $dep"
        fi
    done

    info "Checking permissions:"
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/purr"
    if [ ! -d "$config_dir" ]; then
        error "Missing config directory"
        info "Run 'purr install' to fix"
        errors=$((errors + 1))
    elif [ "$(stat -f "%Op" "$config_dir" | cut -c 4-6)" != "700" ]; then
        error "Incorrect config directory permissions"
        info "Run: chmod 700 $config_dir"
        errors=$((errors + 1))
    else
        success "Config directory permissions OK"
    fi

    info "Checking SSH configuration:"
    if [ ! -d "$HOME/.ssh" ]; then
        error "SSH directory missing"
        info "Run: mkdir -p ~/.ssh && chmod 700 ~/.ssh"
        errors=$((errors + 1))
    elif [ "$(stat -f "%Op" "$HOME/.ssh" | cut -c 4-6)" != "700" ]; then
        error "Incorrect SSH directory permissions"
        info "Run: chmod 700 ~/.ssh"
        errors=$((errors + 1))
    else
        success "SSH configuration OK"
    fi

    if [ "$errors" -eq 0 ]; then
        success "All checks passed!"
        return 0
    else
        error "Found $errors issue(s)"
        return 1
    fi
}
