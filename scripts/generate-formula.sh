#!/bin/sh

set -euo pipefail

VERSION=${1:-$(cat VERSION)}
DESCRIPTION="Key management and authentication tool"
HOMEPAGE="https://github.com/axelop/purr"
LICENSE="MIT"

# Calculate SHA256 of the tarball if it exists
if [ -f "dist/purr-${VERSION}.tar.gz" ]; then
    SHA256=$(shasum -a 256 "dist/purr-${VERSION}.tar.gz" | cut -d' ' -f1)
else
    echo "Error: dist/purr-${VERSION}.tar.gz not found" >&2
    exit 1
fi

# Replace variables in template
sed \
    -e "s/\${VERSION}/${VERSION}/g" \
    -e "s/\${DESCRIPTION}/${DESCRIPTION}/g" \
    -e "s/\${HOMEPAGE}/${HOMEPAGE}/g" \
    -e "s/\${SHA256}/${SHA256}/g" \
    -e "s/\${LICENSE}/${LICENSE}/g" \
    Formula/purr.rb.in > Formula/purr.rb

echo "✓ Generated Formula/purr.rb"
