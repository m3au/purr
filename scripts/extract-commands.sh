#!/bin/bash

set -eu

MAN_FILE="$1"
OUTPUT_FILE="$2"

mkdir -p "$(dirname "$OUTPUT_FILE")"

go-md2man -in "$MAN_FILE" | \
    sed -n '/^COMMANDS/,/^[A-Z]/p' | \
    awk '/^[a-z]/ {cmd=$1; next} /^[[:space:]]+/ {sub(/^[[:space:]]+/, ""); print cmd " " $0}' | \
    grep -v '^[A-Z]' > "$OUTPUT_FILE"
