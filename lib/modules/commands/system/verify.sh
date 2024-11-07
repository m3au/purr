#!/bin/sh
# Verify command functionality

verify_command() {
    printf "➜ Verifying installation...\n"

    # Check installation
    install_dir="${PREFIX:-/usr/local}/bin"
    if [ ! -f "$install_dir/purr" ]; then
        printf "❌ purr is not installed in %s\n" "$install_dir"
        return 1
    fi
    printf "✓ Installation verified\n"

    # Check configuration
    if [ ! -f "$HOME/.purr/config" ]; then
        printf "❌ Configuration file missing\n"
        return 1
    fi
    printf "✓ Configuration exists\n"

    # Verify dependencies
    printf "\n➜ Checking dependencies:\n"
    check_dependency "op" "1Password CLI"
    check_dependency "ssh-agent" "SSH agent"
    check_dependency "gpg" "GPG"
    check_dependency "git" "Git"

    # Verify permissions
    printf "\n➜ Checking permissions:\n"
    if [ -x "$install_dir/purr" ]; then
        printf "✓ Executable permissions OK\n"
    else
        printf "❌ Incorrect executable permissions\n"
        return 1
    fi

    printf "\n✓ Verification complete\n"
}
