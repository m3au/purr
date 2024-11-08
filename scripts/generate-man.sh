#!/bin/bash

set -eu

# Source metadata
. ./metadata.sh

# Extract commands from Makefile
extract_makefile_commands() {
    grep -E '^[a-z-]+:.*?## .*$$' Makefile | \
        sort | \
        awk 'BEGIN {FS = ":.*?## "}; {printf "**%s**\n: %s\n", $1, $2}'
}

# Generate man page
cat > docs/purr.1.md <<EOF
% ${NAME}(1) ${NAME} ${VERSION}
% ${AUTHOR} <${EMAIL}>
% $(date +"%B %Y")

# NAME
${NAME} - ${DESCRIPTION}

# SYNOPSIS
**${NAME}** [*options*] [*command*]

# DESCRIPTION
${DESCRIPTION}

# COMMANDS
$(extract_makefile_commands)

# OPTIONS
**-v**, **--verbose**
: Show detailed output

**-V**, **--version**
: Show version information

**-h**, **--help**
: Show help message

# EXAMPLES
**${NAME}**
: Load keys and configure Git signing

**${NAME} status --keys**
: List all loaded SSH and GPG keys

# FILES
*~/.ssh/*
: SSH key files

*~/.gnupg/*
: GPG key files and configuration

# ENVIRONMENT
**PURR_VAULT**
: 1Password vault name (default: purr)

# SEE ALSO
**ssh-agent**(1), **gpg-agent**(1), **git**(1)
EOF
