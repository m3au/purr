#!/bin/sh

verify_command() {
    info "Verifying installation..."

    install_dir="${PREFIX:-/usr/local}/bin"
    if [ ! -f "$install_dir/purr" ]; then
        error "purr is not installed in $install_dir"
        return 1
    fi
    success "Installation verified"

    if [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/purr/config" ]; then
        error "Configuration file missing"
        return 1
    fi
    success "Configuration exists"

    info "Checking dependencies:"
    check_dependency "op" "1Password CLI"
    check_dependency "ssh-agent" "SSH agent"
    check_dependency "gpg" "GPG"
    check_dependency "git" "Git"

    info "Checking permissions:"
    if [ -x "$install_dir/purr" ]; then
        success "Executable permissions OK"
    else
        error "Incorrect executable permissions"
        return 1
    fi

    success "Verification complete"
}
