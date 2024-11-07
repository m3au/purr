% PURR(1) purr 0.0.1
% m3au <m3au@pm.me>
% March 2024

# NAME

purr - Key management utility integrating 1Password, SSH, and GPG

# SYNOPSIS

**purr** [*options*] [*command*]

# DESCRIPTION

purr manages SSH and GPG keys through 1Password integration, providing secure key loading/unloading and Git signing configuration.

# COMMANDS

**status** [*options*]
: Show current state of all components
    - **-k**, **--keys**: List loaded SSH and GPG keys
    - **-d**, **--debug**: Show detailed system status
    - **-c**, **--check**: Check status of SSH and GPG keys

**lock**
: Unload keys and lock 1Password

**install**
: Install purr on your system

**uninstall**
: Remove purr from your system

**update**
: Check for and install updates

**doctor**
: Run diagnostics and fix common issues

**config** <*subcommand*>
: Manage configuration
    - **get** [*key*]: Show configuration value
    - **set** <*key*> <*value*>: Set configuration value
    - **list**: Show all configuration values

**backup**
: Backup current configuration

**reset**
: Reset to default configuration

**verify**
: Verify installation integrity

**version**
: Show version information

**keys** <*subcommand*>
: Manage SSH and GPG keys
    - **list**: List all loaded keys
    - **load** <*key-name*>: Load a specific key
    - **unload** <*key-name*>: Unload a specific key

# OPTIONS

**-v**, **--verbose**
: Show detailed output

**-V**, **--version**
: Show version information

**-h**, **--help**
: Show help message

# EXAMPLES

**purr**
: Load keys and configure Git signing

**purr status --keys**
: List all loaded SSH and GPG keys

**purr status --debug**
: Show detailed system status

**purr lock**
: Unload keys and lock everything

# FILES

*~/.ssh/*
: SSH key files

*~/.gnupg/*
: GPG key files and configuration

# ENVIRONMENT

**PURR_VAULT**
: 1Password vault name (default: purr)

**PURR_GPG_ITEM**
: 1Password GPG item name (default: purr gpg)

**PURR_GITHUB_ITEM**
: 1Password GitHub item name (default: GitHub)

# SEE ALSO

**ssh-agent**(1), **gpg-agent**(1), **git**(1)
