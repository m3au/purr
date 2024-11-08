#!/bin/sh

colorize() {
    message="$1"
    flags="${2:--a}"

    if [ -n "$NO_COLOR" ]; then
        printf '%s\n' "$message"
        return 0
    fi

    if command -v lolcat >/dev/null 2>&1; then
        printf '%s\n' "$message" | lolcat "$flags"
    else
        printf '%s\n' "$message"
    fi
}
