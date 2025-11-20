# Setup Guide

This guide provides detailed step-by-step instructions for setting up purr.

## Prerequisites

### Required Software

1. **macOS** (purr is currently macOS-only)
2. **ZSH shell** (default on macOS)
3. **1Password Desktop App** with CLI integration enabled
4. **1Password CLI** (`op`)
5. **GPG** (GNU Privacy Guard)

### Installing Prerequisites

#### 1Password CLI

```bash
brew install --cask 1password-cli
```

Then authenticate:

```bash
op signin
```

#### GPG

```bash
brew install gnupg
```

#### Optional: lolcat (for colorful output)

```bash
brew install lolcat
```

## 1Password Setup

### Create Required Vault

1. Open 1Password
2. Create a new vault (or use an existing one)
3. Note the vault name (default: `purr`)

### Create GPG Item

1. In your vault, create a new item (type: "Password" or "Secure Note")
2. Name it `gpg` (or your custom name)
3. Add the following fields:
   - **key_id**: Your GPG key ID (e.g., `ABC123DEF456`)
   - **password**: Your GPG key passphrase
   - **public_key**: Your public GPG key (full key, including `-----BEGIN PGP PUBLIC KEY BLOCK-----`)
   - **private_key**: Your private GPG key (full key, including `-----BEGIN PGP PRIVATE KEY BLOCK-----`)

### Create GitHub Item

1. In your vault, create a new item (type: "Password" or "Login")
2. Name it `GitHub` (or your custom name)
3. Add the following fields:
   - **username** (or `user`, or `login`): Your GitHub username
   - **email** (or `mail`, or `email address`): Your GitHub email
   - **pat** (or `token`, or `access token`, or `personal access token`, or `password`): Your GitHub Personal Access Token

### Generate GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with appropriate scopes (minimum: `repo`)
3. Copy the token and add it to your GitHub item in 1Password

## Installation

### Manual Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/m3au/purr.git ~/.zsh/purr
   ```

2. Source the script in your `~/.zshrc`:

   ```zsh
   source ~/.zsh/purr/purr.zsh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Using a Plugin Manager

See the main [README.md](../README.md) for plugin manager installation instructions.

## Configuration (Optional)

Create `~/.purrrc` to customize settings:

```zsh
# Custom vault and item names
export PURR_VAULT_NAME="my-vault"
export PURR_GPG_ITEM="my-gpg-item"
export PURR_GITHUB_ITEM="my-github-item"

# Custom SSH agent socket path
export PURR_SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# Custom GPG cache TTL (in seconds)
export PURR_GPG_CACHE_TTL=3600  # 1 hour instead of default ~400 days
```

## Verification

Test the installation:

```bash
purr check
```

If everything is configured correctly, you should see status information about your keys.

## First Use

Run `purr` to load your keys:

```bash
purr
```

This will:

- Connect to 1Password SSH agent
- Load your GPG keys
- Configure Git commit signing
- Set up GitHub credentials

When finished, lock your keys:

```bash
purr lock
```

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.
