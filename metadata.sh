#!/bin/sh
# Project metadata used by build scripts and package managers

NAME=purr
VERSION=$(cat VERSION 2>/dev/null || echo "0.0.0")
DESCRIPTION="Key management utility integrating 1Password, SSH, and GPG"
AUTHOR=m3au
EMAIL=m3au@pm.me
HOMEPAGE=https://github.com/m3au/purr
LICENSE=MIT

# Dependencies (colon-separated type)
DEPENDS="\
go-md2man:build \
shellcheck:build \
shfmt:build \
1password-cli:runtime \
gnupg:runtime \
git:runtime"

# Optional dependencies
SUGGESTS=lolcat
