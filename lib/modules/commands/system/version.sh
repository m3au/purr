#!/bin/sh
# Version information functionality

version_command() {
    version="0.0.1"
    commit=""

    if command -v git >/dev/null 2>&1 && [ -d "$PURR_ROOT/.git" ]; then
        # Get git information if available
        commit=$(cd "$PURR_ROOT" && git rev-parse --short HEAD 2>/dev/null)
        tag=$(cd "$PURR_ROOT" && git describe --tags 2>/dev/null)

        if [ -n "$tag" ]; then
            version="$tag"
        fi
    fi

    if [ -n "$1" ] && [ "$1" = "--short" ]; then
        printf "%s\n" "$version"
        return
    fi

    printf "purr version %s" "$version"
    if [ -n "$commit" ]; then
        printf " (%s)" "$commit"
    fi
    printf "\n"
}
