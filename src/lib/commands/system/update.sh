#!/bin/sh

. "${PURR_ROOT}/lib/core/common.sh"

update_command() {
    info "Checking for updates..."

    if ! command -v git >/dev/null 2>&1; then
        error "Git is required for updates"
        return 1
    fi

    cd "$PURR_ROOT" || exit 1

    git fetch origin >/dev/null 2>&1 || {
        error "Failed to fetch updates"
        return 1
    }

    local_rev=$(git rev-parse HEAD)
    remote_rev=$(git rev-parse origin/main)

    if [ "$local_rev" = "$remote_rev" ]; then
        success "Already up to date (version ${PURR_VERSION})"
        return 0
    fi

    current_tag=$(git describe --tags 2>/dev/null || echo "${PURR_VERSION}")
    latest_tag=$(git describe --tags origin/main 2>/dev/null || echo "unknown")

    info "New version available: $current_tag -> $latest_tag"
    info "Update now? [Y/n] "
    read -r do_update
    case "$do_update" in
        [Nn]*)
            return 0
            ;;
    esac

    backup_command || {
        error "Failed to backup configuration"
        return 1
    }

    git pull origin main >/dev/null 2>&1 || {
        error "Update failed"
        return 1
    }

    install_command || {
        error "Failed to reinstall after update"
        return 1
    }

    success "Updated to version $latest_tag"
    info "Please restart your shell or run: source ~/.$(basename "$SHELL")rc"
}
