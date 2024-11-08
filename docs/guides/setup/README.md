# Setup Guide <!-- omit in toc -->

![purr](https://github.com/m3au/store/blob/main/docs/purr.png)

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
  - [GitHub Setup](#github-setup)
  - [1Password Setup](#1password-setup)
  - [Touch ID Setup](#touch-id-setup)
- [Environment Variables](#environment-variables)

---

## Prerequisites

Install required components:

```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install core dependencies
brew install --cask 1password
brew install --cask 1password-cli
brew install gnupg

# Optional dependencies
brew install lolcat
```

Configure SSH for 1Password:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "Host *
  IdentityAgent ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" > ~/.ssh/config
```

## Installation

Clone the repository:

```bash
git clone https://github.com/m3au/purr.git
cd purr
```

Add to your shell config:

```bash
# Add to your .zshrc
echo '# purr - Key management utility' >> ~/.zshrc
echo 'export PURR_HOME="$HOME/_/dev/purr"' >> ~/.zshrc
echo '[ -s "$PURR_HOME/lib/purr" ] && . "$PURR_HOME/lib/purr"' >> ~/.zshrc
```

Reload your shell:

```bash
source ~/.zshrc
```

## Configuration

### GitHub Setup

1. Create a new Personal Access Token (Classic):
   - Go to GitHub Settings → Developer Settings → [Personal Access Tokens (Classic)](https://github.com/settings/tokens)
   - Click "Generate new token (classic)"
   - Name it something like "purr-cli"
   - Select these scopes:
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)
     - `write:packages` (Upload packages)
     - `delete:packages` (Delete packages)
     - `admin:gpg_key` (Manage GPG keys)
   - Click "Generate token"
   - **Important**: Copy your token immediately - you won't be able to see it again!

### 1Password Setup

1. Create a dedicated vault in 1Password:
   - Open 1Password
   - Click "Add Vault" (+ icon)
   - Name it "purr" (or set custom name via `PURR_VAULT`)

2. Create required items in the vault:

   a. Create "Login" item named "gpg":
   - Title: `gpg`
   - Custom fields:
     - `key_id`: Your GPG key ID (e.g., "819B065CAC953C07E834B416121EEAD62DC2067B")
     - `password`: Your GPG key password
     - `public_key`: Your full GPG public key (including BEGIN/END blocks)
     - `private_key`: Your full GPG private key (including BEGIN/END blocks)

   b. Create "Login" item named "github":
   - Title: `github`
   - Custom fields:
     - `username`: Your GitHub username
     - `email`: Your GitHub email
     - `pat`: Your GitHub Personal Access Token (from GitHub Setup)

   c. Create "Login" item named "ssh":
   - Title: `ssh`
   - Custom fields:
     - `public_key`: Your SSH public key
     - `private_key`: Your SSH private key
     - `password`: Your SSH key password (if any)
     - `key_type`: The key type (e.g., "Ed25519")
     - `fingerprint`: The key fingerprint

### Touch ID Setup

1. Enable Touch ID for terminal commands:

    ```bash
    # Install and configure pinentry-mac
    brew install pinentry-mac
    echo "pinentry-program $(which pinentry-mac)" > ~/.gnupg/gpg-agent.conf
    chmod 700 ~/.gnupg
    gpgconf --kill gpg-agent

    # Enable Touch ID for sudo
    sudo sh -c 'echo "auth sufficient pam_tid.so" >> /etc/pam.d/sudo'
    ```

2. Configure your terminal:
   - **iTerm2**: Preferences → Advanced → Enable "Allow Touch ID authentication"
   - **Terminal.app**: Works out of the box
   - **VS Code**: Settings → Search for "terminal.integrated.enableTouchId" → Enable

## Environment Variables

```bash
# Vault and item names
PURR_VAULT="${PURR_VAULT:-purr}"               # Default vault name
PURR_GPG_ITEM="${PURR_GPG_ITEM:-gpg}"          # Default GPG item name
PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-github}" # Default GitHub item name
PURR_SSH_ITEM="${PURR_SSH_ITEM:-ssh}"          # Default SSH item name

# GitHub field names
PURR_GITHUB_USERNAME_FIELD="${PURR_GITHUB_USERNAME_FIELD:-username}"
PURR_GITHUB_EMAIL_FIELD="${PURR_GITHUB_EMAIL_FIELD:-email}"
PURR_GITHUB_PAT_FIELD="${PURR_GITHUB_PAT_FIELD:-pat}"

# GPG field names
PURR_GPG_KEY_ID_FIELD="${PURR_GPG_KEY_ID_FIELD:-key_id}"
PURR_GPG_PASSWORD_FIELD="${PURR_GPG_PASSWORD_FIELD:-password}"
PURR_GPG_PUBLIC_FIELD="${PURR_GPG_PUBLIC_FIELD:-public_key}"
PURR_GPG_PRIVATE_FIELD="${PURR_GPG_PRIVATE_FIELD:-private_key}"

# SSH field names
PURR_SSH_PUBLIC_FIELD="${PURR_SSH_PUBLIC_FIELD:-public_key}"
PURR_SSH_PRIVATE_FIELD="${PURR_SSH_PRIVATE_FIELD:-private_key}"
PURR_SSH_PASSWORD_FIELD="${PURR_SSH_PASSWORD_FIELD:-password}"
PURR_SSH_TYPE_FIELD="${PURR_SSH_TYPE_FIELD:-key_type}"
PURR_SSH_FINGERPRINT_FIELD="${PURR_SSH_FINGERPRINT_FIELD:-fingerprint}"
```

These variables let you customize the names of 1Password vaults, items, and fields. The default values are shown above - you only need to set them if you want to use different names.
