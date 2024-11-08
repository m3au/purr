#!/bin/bash

set -eu

CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "0.0.0")

increment_patch() {
    local version="$CURRENT_VERSION"
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    echo "$major.$minor.$((patch + 1))"
}

increment_minor() {
    local version="$CURRENT_VERSION"
    local major minor
    IFS='.' read -r major minor _ <<< "$version"
    echo "$major.$((minor + 1)).0"
}

increment_major() {
    local version="$CURRENT_VERSION"
    local major
    IFS='.' read -r major _ _ <<< "$version"
    echo "$((major + 1)).0.0"
}

case "${1:-}" in
    patch) increment_patch ;;
    minor) increment_minor ;;
    major) increment_major ;;
    *) echo "$CURRENT_VERSION" ;;
esac
