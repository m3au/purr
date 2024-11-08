#!/bin/bash

set -eu

NEXT_VERSION="$1"
SKIP_GIT="${SKIP_GIT:-0}"
SKIP_TEST="${SKIP_TEST:-0}"

echo "Publishing version $NEXT_VERSION..."
echo "$NEXT_VERSION" > VERSION

# Generate documentation and completions
mkdir -p dist/{man,completion}

if command -v go-md2man >/dev/null 2>&1; then
    go-md2man -in docs/purr.1.md -out dist/man/purr.1
fi

if [ -f "docs/purr.1.md" ]; then
    ./scripts/completions.sh docs/purr.1 dist/completion
fi

# Create distribution
make dist

# Generate Homebrew formula
if command -v generate-formula.sh >/dev/null 2>&1; then
    generate-formula.sh
fi

# Git operations
if [ "$SKIP_GIT" = "0" ]; then
    git add VERSION dist/purr-"$NEXT_VERSION".tar.gz dist/man/purr.1 Formula/purr.rb
    git commit -m "Release v$NEXT_VERSION"
    git tag -a "v$NEXT_VERSION" -m "Release v$NEXT_VERSION"
fi

# Run tests
if [ "$SKIP_TEST" = "0" ]; then
    make test test-dist
fi

echo "✨ Published v$NEXT_VERSION"
