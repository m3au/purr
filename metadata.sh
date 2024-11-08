#!/bin/sh
# Project metadata used by build scripts and package managers

export NAME='purr'
VERSION=$(cat VERSION 2>/dev/null || echo "0.0.0")
export VERSION
export DESCRIPTION='Key management utility integrating 1Password, SSH, and GPG'
export AUTHOR='m3au'
export EMAIL='m3au@pm.me'
export HOMEPAGE='https://github.com/m3au/purr'
export LICENSE='MIT'

# Dependencies (colon-separated type)
export DEPENDS='\
go-md2man:build \
shellcheck:build \
shfmt:build \
1password-cli:runtime \
gnupg:runtime \
git:runtime'

# Optional dependencies
export SUGGESTS='lolcat'
