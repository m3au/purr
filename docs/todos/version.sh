#!/usr/bin/env bash

set -euo pipefail

# Get version type
TYPE="${1:-}"

if [[ -z "$TYPE" ]]; then
    echo "Usage: $0 [patch|minor|major]" >&2
    exit 1
fi

# Read current version
if [[ ! -f VERSION ]]; then
    echo "0.0.0" > VERSION
fi
VERSION=$(cat VERSION)

# Split version into components
IFS='.' read -r major minor patch <<< "$VERSION"

# Increment version based on type
case "$TYPE" in
    patch)
        ((patch++))
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    *)
        echo "Invalid version type: $TYPE" >&2
        exit 1
        ;;
esac

# Create new version string
NEW_VERSION="${major}.${minor}.${patch}"

# Update VERSION file
echo "$NEW_VERSION" > VERSION

# Output new version
echo "$NEW_VERSION"
