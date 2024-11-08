#!/bin/bash

set -eu

VERSION="${1:-0.0.0}"
MODE="${2:-release}"  # release or test

if [ "$MODE" = "test" ]; then
    DIST_DIR="tests/dev/dist"
    PREFIX="purr-test"
    echo "Creating test distribution archive..."
else
    DIST_DIR="dist"
    PREFIX="purr-$VERSION"
    echo "Creating release distribution archive..."
fi

# Create distribution structure
mkdir -p "$DIST_DIR/$PREFIX"/{man,completion}

# Copy only runtime files
cp -r src/bin src/lib "$DIST_DIR/$PREFIX/"
cp -r dist/man/* "$DIST_DIR/$PREFIX/man/"
cp -r dist/completion/* "$DIST_DIR/$PREFIX/completion/"

# Copy documentation
cp LICENSE README.md VERSION "$DIST_DIR/$PREFIX/"

# Copy install script
cp install "$DIST_DIR/$PREFIX/"

# Create archive
cd "$DIST_DIR" && tar czf "$PREFIX.tar.gz" "$PREFIX"
rm -rf "$PREFIX"
