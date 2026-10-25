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

   To load it only when you run the command, use a wrapper. `purr.zsh` is written to be sourced that way:

   ```zsh
   purr() {
     unfunction purr
     source ~/.zsh/purr/purr.zsh
     purr "$@"
   }
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

After setup, check the machine without calling 1Password:

```bash
purr check
```

`purr check` exits 0 when SSH, the GPG secret key, and Git signing are in place. It prints a warning for optional gaps such as GitHub auth or a GPG passphrase that is not cached.

## First Use

Run `purr` once on a new machine:

```bash
purr
```

This will:

- Write the 1Password `IdentityAgent` into `~/.ssh/config` if it is not already there
- Import your GPG secret key from 1Password only when the keyring does not have it
- Set Git commit signing (`user.signingkey`, `commit.gpgsign`, `gpg.program`)
- Set a GitHub token from `gh auth token` when `gh` is authenticated, otherwise from 1Password

Running `purr` again skips those steps. `purr lock` removes the GPG signing key and signs out of the 1Password CLI. The `IdentityAgent` line stays, so the next setup only has to import the key again.

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.
