#!/bin/sh
# Update command functionality

update_command() {
    printf "➜ Checking for updates...\n"

    # Get current version
    current_version=$(version_command)

    # Check latest version from git
    if ! command -v git >/dev/null 2>&1; then
        printf "❌ Git is required for updates\n"
        return 1
    fi

    # Fetch latest version
    cd "$PURR_ROOT" || exit 1
    git fetch origin >/dev/null 2>&1 || {
        printf "❌ Failed to fetch updates\n"
        return 1
    }

    latest_version=$(git describe --tags origin/main 2>/dev/null || echo "unknown")

    if [ "$current_version" = "$latest_version" ]; then
        printf "✓ Already up to date (%s)\n" "$current_version"
        return 0
    fi

    printf "New version available: %s -> %s\n" "$current_version" "$latest_version"
    printf "Update now? [Y/n] "
    read -r do_update
    case "$do_update" in
    [Nn]*)
        return 0
        ;;
    esac

    # Perform update
    git pull origin main >/dev/null 2>&1 || {
        printf "❌ Update failed\n"
        return 1
    }

    # Reinstall
    install_command

    printf "✓ Updated to version %s\n" "$latest_version"
}
