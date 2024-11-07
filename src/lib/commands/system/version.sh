#!/bin/sh

. "${PURR_ROOT}/lib/core/common.sh"

version_command() {
    if [ "$1" = "--short" ]; then
        echo "${PURR_VERSION}"
        return 0
    fi

    cat << EOF
purr - key management tool
version: $([ "$1" = "--version" ] && echo "v${PURR_VERSION}" || echo "${PURR_VERSION}")
license: MIT License
website: https://github.com/m3au/purr
EOF
}
