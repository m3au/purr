#!/bin/bash

set -eu

# Source metadata
. ./metadata.sh

# Calculate SHA256 of the release tarball
SHA256=$(shasum -a 256 "dist/purr-${VERSION}.tar.gz" | cut -d' ' -f1)

# Generate dependencies
DEPENDS_STR=""
for dep in "${DEPENDS[@]}"; do
    IFS=':' read -r name type <<< "$dep"
    if [ -n "$type" ]; then
        DEPENDS_STR+="  depends_on \"$name\" => :$type\n"
    else
        DEPENDS_STR+="  depends_on \"$name\"\n"
    fi
done

# Generate formula from template
sed \
    -e "s/\${DESCRIPTION}/$DESCRIPTION/" \
    -e "s/\${HOMEPAGE}/$HOMEPAGE/" \
    -e "s/\${VERSION}/$VERSION/" \
    -e "s/\${SHA256}/$SHA256/" \
    -e "s/\${LICENSE}/$LICENSE/" \
    -e "s/\${DEPENDS}/$DEPENDS_STR/" \
    Formula/purr.rb.in > Formula/purr.rb
