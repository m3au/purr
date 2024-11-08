#!/bin/sh

set -euo pipefail

VERSION="${1:-$(cat VERSION)}"

echo "Creating distribution package v${VERSION}..."

# Create test distribution directory
mkdir -p tests/dist/{man,completion}

# Generate install scripts
./scripts/install.sh --generate --test > tests/dist/install
chmod +x tests/dist/install

# For actual distribution (only when not testing)
if [ "$PURR_TEST" != "1" ]; then
    # Create distribution directories
    mkdir -p dist/{man,completion}

    # Generate install script
    ./scripts/install.sh --generate > dist/install
    chmod +x dist/install

    # Generate documentation
    if command -v go-md2man >/dev/null 2>&1; then
        go-md2man -in docs/purr.1.md -out dist/man/purr.1
    fi

    # Generate completions
    if [ -f "docs/purr.1.md" ]; then
        ./scripts/completions.sh docs/purr.1 dist/completion
    fi

    # Create distribution tarball
    tar -czf "dist/purr-${VERSION}.tar.gz" \
        --transform "s,^,purr-${VERSION}/," \
        src LICENSE README.md VERSION install
fi

echo "✓ Created distribution package v${VERSION}"
