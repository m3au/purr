#!/bin/sh
# Color and formatting utilities

colorize() {
    message="$1"
    flags="${2:--a}"

    # Check for NO_COLOR environment variable (standard)
    if [ -n "$NO_COLOR" ]; then
        printf '%s\n' "$message"
        return 0
    fi

    # Try lolcat, fallback silently to regular output
    if command -v lolcat >/dev/null 2>&1; then
        printf '%s\n' "$message" | lolcat "$flags"
    else
        printf '%s\n' "$message"
    fi
}
