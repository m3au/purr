#!/bin/sh

set -euo pipefail

NEXT_VERSION="$1"
SKIP_GIT="${SKIP_GIT:-0}"
SKIP_TEST="${SKIP_TEST:-0}"

echo "Publishing version $NEXT_VERSION..."

# Update version
echo "$NEXT_VERSION" > VERSION

# Create distribution
make dist

# Run tests
if [ "$SKIP_TEST" = "0" ]; then
    make test
fi

# Git operations
if [ "$SKIP_GIT" = "0" ]; then
    git add VERSION dist/purr-"$NEXT_VERSION".tar.gz dist/man/purr.1 Formula/purr.rb
    git commit -m "Release v$NEXT_VERSION"
    git tag -a "v$NEXT_VERSION" -m "Release v$NEXT_VERSION"
fi

echo "✨ Published v$NEXT_VERSION"
