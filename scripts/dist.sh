#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>" >&2
    exit 1
fi

# Set root directory based on environment
if [[ "${PURR_TEST:-}" == "1" ]]; then
    ROOT_DIR="tests/root"
else
    ROOT_DIR="dist"
fi

# Create distribution structure
mkdir -p "$ROOT_DIR"/{man,completion}

# Copy files
cp -r src/completion/* "$ROOT_DIR/completion/"
cp -r docs/purr.1 "$ROOT_DIR/man/"

# Create archive
tar -czf "$ROOT_DIR/purr-${VERSION}.tar.gz" -C "$ROOT_DIR" man completion

echo "✓ Created distribution in $ROOT_DIR"
