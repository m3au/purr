# Configuration Reference

Complete reference for all configuration options in purr.

## Environment Variables

All configuration is done via environment variables. You can set these in your `~/.zshrc` or `~/.purrrc` file.

### 1Password Configuration

#### `PURR_VAULT_NAME`

- **Default**: `purr`
- **Description**: Name of the 1Password vault containing your GPG and GitHub items
- **Example**: `export PURR_VAULT_NAME="my-vault"`

#### `PURR_GPG_ITEM`

- **Default**: `gpg`
- **Description**: Name of the 1Password item containing your GPG key information
- **Example**: `export PURR_GPG_ITEM="my-gpg-key"`

#### `PURR_GITHUB_ITEM`

- **Default**: `GitHub`
- **Description**: Name of the 1Password item containing your GitHub credentials
- **Example**: `export PURR_GITHUB_ITEM="MyGitHub"`

### SSH Configuration

#### `PURR_SSH_AUTH_SOCK`

- **Default**: `$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- **Description**: Path to the 1Password SSH agent socket
- **Example**: `export PURR_SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"`

### GPG Configuration

#### `PURR_GPG_CACHE_TTL`

- **Default**: `34560000` (approximately 400 days)
- **Description**: GPG agent cache time-to-live in seconds. Controls how long the GPG passphrase is cached
- **Example**: `export PURR_GPG_CACHE_TTL=3600` (1 hour)
- **Security Note**: A longer TTL means fewer passphrase prompts but passphrases remain cached longer

## Configuration File

You can create a `~/.purrrc` file to store all your configuration:

```zsh
# purr configuration file
# This file is sourced automatically when purr.zsh is loaded

# 1Password settings
export PURR_VAULT_NAME="purr"
export PURR_GPG_ITEM="gpg"
export PURR_GITHUB_ITEM="GitHub"

# SSH settings
export PURR_SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# GPG settings
export PURR_GPG_CACHE_TTL=34560000
```

The `~/.purrrc` file is sourced after default environment variable values are set, so it can override defaults.

## Configuration Precedence

Configuration values are resolved in this order:

1. **Environment variables** (highest priority)
2. **`~/.purrrc` file** (if it exists)
3. **Defaults** (lowest priority)

This means environment variables set in your shell will override values in `~/.purrrc`.

## Examples

### Different Vault Per Project

```zsh
# In your project directory
export PURR_VAULT_NAME="project-secrets"
purr
```

### Shorter GPG Cache for Security

```zsh
# In ~/.purrrc
export PURR_GPG_CACHE_TTL=3600  # 1 hour
```

### Custom SSH Agent Socket

```zsh
# In ~/.purrrc
export PURR_SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
```

## Verification

Check your current configuration:

```bash
echo "Vault: ${PURR_VAULT_NAME:-purr}"
echo "GPG Item: ${PURR_GPG_ITEM:-gpg}"
echo "GitHub Item: ${PURR_GITHUB_ITEM:-GitHub}"
echo "SSH Socket: ${PURR_SSH_AUTH_SOCK:-default}"
echo "GPG TTL: ${PURR_GPG_CACHE_TTL:-34560000}"
```
