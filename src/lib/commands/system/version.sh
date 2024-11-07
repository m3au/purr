#!/bin/sh

. "${PURR_ROOT}/lib/modules/core/common.sh"

version_command() {
    if [ "$1" = "--short" ]; then
        if command -v git >/dev/null 2>&1 && [ -d "$PURR_ROOT/.git" ]; then
            git describe --tags 2>/dev/null && return 0
        fi
        echo "0.0.1"
        return 0
    fi

    if command -v git >/dev/null 2>&1 && [ -d "$PURR_ROOT/.git" ]; then
        tag=$(git describe --tags 2>/dev/null)
        commit=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$tag" ] && [ -n "$commit" ]; then
            printf "purr version %s (%s)\n" "$tag" "$commit"
            return 0
        fi
    fi

    printf "purr version 0.0.1\n"
}
