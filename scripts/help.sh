#!/usr/bin/env bash

set -euo pipefail

# Print header
echo "Usage: make [target]"
echo ""
echo "Targets:"

# Format and print targets
awk '
    BEGIN { FS = ":.*?## "; }
    /^[a-zA-Z_-]+:.*?## / {
        printf "  %-20s %s\n", $1, $2;
    }
' Makefile | sort
