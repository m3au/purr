#!/bin/sh
# System diagnostics and repair functionality

doctor_command() {
    printf "➜ Running system diagnostics...\n\n"
    errors=0

    # Check installation
    printf "Checking installation:\n"
    install_dir="${PREFIX:-/usr/local}/bin"
    if [ ! -f "$install_dir/purr" ]; then
        printf "❌ purr not found in %s\n" "$install_dir"
        printf "   Run 'purr install' to fix\n"
        errors=$((errors + 1))
    else
        printf "✓ Installation verified\n"
    fi

    # Check configuration
    printf "\nChecking configuration:\n"
    if ! validate_config; then
        errors=$((errors + 1))
    fi

    # Check dependencies
    printf "\nChecking dependencies:\n"
    for dep in op ssh-agent gpg git; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            printf "❌ Missing dependency: %s\n" "$dep"
            errors=$((errors + 1))
        else
            printf "✓ Found %s\n" "$dep"
        fi
    done

    # Check permissions
    printf "\nChecking permissions:\n"
    config_dir="$HOME/.purr"
    if [ ! -d "$config_dir" ]; then
        printf "❌ Missing config directory\n"
        printf "   Run 'purr install' to fix\n"
        errors=$((errors + 1))
    elif [ "$(stat -f "%Op" "$config_dir" | cut -c 4-6)" != "700" ]; then
        printf "❌ Incorrect config directory permissions\n"
        printf "   Run: chmod 700 %s\n" "$config_dir"
        errors=$((errors + 1))
    else
        printf "✓ Config directory permissions OK\n"
    fi

    # Check SSH configuration
    printf "\nChecking SSH configuration:\n"
    if [ ! -d "$HOME/.ssh" ]; then
        printf "❌ SSH directory missing\n"
        printf "   Run: mkdir -p ~/.ssh && chmod 700 ~/.ssh\n"
        errors=$((errors + 1))
    elif [ "$(stat -f "%Op" "$HOME/.ssh" | cut -c 4-6)" != "700" ]; then
        printf "❌ Incorrect SSH directory permissions\n"
        printf "   Run: chmod 700 ~/.ssh\n"
        errors=$((errors + 1))
    else
        printf "✓ SSH configuration OK\n"
    fi

    # Summary
    printf "\n➜ Diagnostics complete: "
    if [ "$errors" -eq 0 ]; then
        printf "✨ All checks passed!\n"
        return 0
    else
        printf "Found %d issue(s)\n" "$errors"
        return 1
    fi
}
