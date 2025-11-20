# 🐱 purr

![purr](https://github.com/m3au/store/blob/main/docs/purr.png)

[![CI](https://github.com/m3au/purr/workflows/CI/badge.svg)](https://github.com/m3au/purr/actions) [![License](https://img.shields.io/github/license/m3au/purr)](LICENSE) [![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![ZSH Plugin](https://img.shields.io/badge/ZSH-Plugin-blue)](https://github.com/unixorn/awesome-zsh-plugins) [![macOS](https://img.shields.io/badge/macOS-supported-success)](https://github.com/m3au/purr#prerequisites) [![1Password](https://img.shields.io/badge/1Password-integrated-blue)](https://1password.com/) [![GPG](https://img.shields.io/badge/GPG-enabled-brightgreen)](https://gnupg.org/) [![SSH](https://img.shields.io/badge/SSH-supported-yellow)](https://www.ssh.com/)

A ZSH plugin for seamless key management that integrates 1Password, SSH, and GPG. Securely loads and unloads keys, configures Git signing, and manages GitHub credentials - all with a simple purr command.

## 🚀 Features

- 🔐 Seamless integration with 1Password for secure key storage
- 🔑 Automated SSH key management
- 📝 GPG key handling and Git commit signing
- 🔄 GitHub credentials configuration
- 🔒 Secure key unloading with lock command (including mcp.json cleanup)
- 🔍 Key status checking capabilities
- 🎯 GitHub token configuration for Cursor MCP servers

## 👥 Who is this for?

purr is designed for developers and teams who want a unified, automated solution for managing SSH keys, GPG keys, and Git signing. Perfect for:

- **1Password Users**: Developers already using 1Password for credential management who want to leverage it for SSH/GPG keys
- **Security-Conscious Teams**: Organizations requiring Git commit signing and secure key management practices
- **Daily Developers**: Developers who want a single command to load all keys and configure their development environment
- **Team Leads**: Those setting up standardized development environments across team members
- **DevOps Engineers**: Professionals managing multiple machines who need consistent key management workflows
- **macOS Users**: Developers on macOS who need seamless integration with system tools and 1Password

### Use Cases

- **Daily Development Workflow**: Load all keys at the start of your day with a single `purr` command
- **New Machine Setup**: Quickly configure a new development machine with all necessary keys and Git signing
- **Team Onboarding**: Provide consistent setup instructions for new team members
- **Secure Key Rotation**: Easily rotate keys stored in 1Password without manual configuration
- **Temporary Development Environments**: Load keys when needed, lock them when done
- **CI/CD Key Management**: Future support for automated key management in CI/CD pipelines

## 📋 Prerequisites

### Required

- macOS
- ZSH shell
- 1Password CLI (`op`) installed and configured
- GPG installed (`brew install gnupg`)
- SSH client (built into macOS)

### Optional

- lolcat for colorful output (`brew install lolcat`)

## 🛠 Installation

### Prerequisites Setup

1. **Install 1Password CLI**:

   ```bash
   brew install --cask 1password-cli
   ```

   Then authenticate: `op signin`

2. **Install GPG** (if not already installed):

   ```bash
   brew install gnupg
   ```

3. **Install lolcat** (optional, for colorful output):
   ```bash
   brew install lolcat
   ```

### Manual Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/m3au/purr.git ~/.zsh/purr
   ```

2. Source the script in your ZSH configuration (`~/.zshrc`):

   ```zsh
   source ~/.zsh/purr/purr.zsh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Using a ZSH Plugin Manager

#### [antidote](https://github.com/mattmc3/antidote)

Add to your `.zplugins.txt`:

```
m3au/purr
```

Then run `antidote bundle` or restart your shell.

#### [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

1. Clone into custom plugins directory:

   ```bash
   git clone https://github.com/m3au/purr.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/purr
   ```

2. Add to your `.zshrc` plugins array:
   ```zsh
   plugins=(... purr)
   ```

## ⚙️ Configuration

### 1Password Setup

Before using purr, you need to set up your 1Password vault with the required items:

#### Required Vault Structure

Create a vault (default name: `purr`) with the following items:

1. **GPG Item** (default name: `gpg`)

   - Required fields:
     - `key_id`: Your GPG key ID (e.g., `ABC123DEF456`)
     - `password`: Your GPG key passphrase
     - `public_key`: Your public GPG key (paste full key)
     - `private_key`: Your private GPG key (paste full key)

2. **GitHub Item** (default name: `GitHub`)
   - Required fields (one of the following field names):
     - Username: `username`, `user`, or `login`
     - Email: `email`, `mail`, or `email address`
     - Personal Access Token: `pat`, `token`, `access token`, `personal access token`, or `password`

#### Customizing Vault and Item Names

You can customize the vault and item names via environment variables:

```zsh
# In your ~/.zshrc or ~/.purrrc
export PURR_VAULT_NAME="my-vault-name"
export PURR_GPG_ITEM="my-gpg-item"
export PURR_GITHUB_ITEM="my-github-item"
```

Alternatively, create a `~/.purrrc` file:

```zsh
# purr configuration
export PURR_VAULT_NAME="purr"
export PURR_GPG_ITEM="gpg"
export PURR_GITHUB_ITEM="GitHub"
```

Then source it in your `.zshrc` before sourcing purr:

```zsh
[ -f ~/.purrrc ] && source ~/.purrrc
source ~/.zsh/purr/purr.zsh
```

## 🚀 Quick Start

Get up and running in 3 steps:

1. **Install purr**:

   ```bash
   git clone https://github.com/m3au/purr.git ~/.zsh/purr
   echo "source ~/.zsh/purr/purr.zsh" >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Configure 1Password**: Create a vault with GPG and GitHub items (see [Setup Guide](docs/setup.md))

3. **Use it**:
   ```bash
   purr        # Load all keys and configure Git signing
   purr check  # Verify everything is set up correctly
   purr lock   # Unload keys when done
   ```

That's it! Your keys are loaded and Git signing is configured. See [Usage](#-usage) for more details.

## 🔑 Usage

### Implemented Commands

- `purr` - Loads keys and configures Git signing
- `purr lock` - Unloads keys and locks 1Password
- `purr check` - Checks key status
- `purr -v` - Verbose mode for any command
- `purr -h` - Shows help message

### Common Workflows

#### Daily Development Workflow

```bash
# Morning: Load all keys
purr

# Verify everything is working
purr check

# Make commits (automatically signed)
git commit -m "Your commit message"

# End of day: Lock everything
purr lock
```

#### Setting Up a New Machine

```bash
# Install purr
git clone https://github.com/m3au/purr.git ~/.zsh/purr
echo "source ~/.zsh/purr/purr.zsh" >> ~/.zshrc

# Configure 1Password vault with GPG and GitHub items
# (see docs/setup.md for details)

# Load keys
purr

# Verify setup
purr check
```

#### Troubleshooting

```bash
# Check status with verbose output
purr check -v

# Try loading keys with verbose output
purr -v
```

### Examples

#### Example 1: Basic Usage

```bash
# Load all keys and configure Git signing
$ purr
ᓚᘏᗢ purr initializing...
✅ 1Password is running and authenticated
Connected to 1Password SSH agent.
GPG key loaded successfully and Git configured for signing.

Credentials loaded:
GitHub: your-username
GitHub Token: ghp_****...****7890
Git signing: Enabled
GPG: ABC1****...****2345
SSH: Connected
ᓚᘏᗢ purr
```

#### Example 2: Checking Status

```bash
$ purr check
Checking for SSH keys:
  SSH keys found:
    ~/.ssh/id_rsa
    ~/.ssh/id_ed25519

Checking SSH agent connection:
  Connected to SSH agent at ~/Library/Group Containers/.../agent.sock
  Loaded keys: 3

Checking for GPG keys:
  GPG keys found:
    Key ID: ABC123DEF456
    Name: Your Name <your@email.com>

Checking Git GPG signing status:
  Git GPG signing is enabled.
    Signing key: ABC123DEF456

Checking GitHub token status:
  GITHUB_TOKEN environment variable: Set (ghp_****...****7890)
```

#### Example 3: Locking Keys

```bash
$ purr lock
System locked
ᓚᘏᗢ hiss

# Verify keys are unloaded
$ purr check
Checking SSH agent connection:
  Not connected to any SSH agent.

Checking for GPG keys:
  No GPG keys found on this system.
```

### GitHub Token Management

When running `purr`, the GitHub Personal Access Token is:

- Exported as `GITHUB_TOKEN` environment variable
- Unset when running `purr lock`
- Shown in obfuscated format (first 4 and last 4 chars visible)

### Current Implementation

The default `purr` command already handles:

- ✅ 1Password integration (authentication and credential retrieval)
- ✅ SSH key management (loads from 1Password SSH agent)
- ✅ GPG key management (imports and configures Git signing)
- ✅ GitHub credentials (configures Git user, email, and stores token in keychain)
- ✅ Git signing (enables GPG commit signing)

Additional commands available:

- `purr check` - Check status of all keys
- `purr lock` - Unload all keys and lock 1Password

### Coming Soon

- `purr github` - Standalone GitHub credential management
- `purr ssh` - Standalone SSH key operations
- `purr gpg` - Standalone GPG key operations
- `purr op` - 1Password CLI shortcuts
- `purr key` - Key obfuscation utilities

## 🗺 Roadmap

### Password Manager Integration

- [ ] Bitwarden support
- [ ] KeePassXC support
- [ ] LastPass support
- [ ] Dashlane support

### Key Management

- [ ] YubiKey integration
- [ ] Multiple key profile support
- [ ] Key rotation automation
- [ ] Backup and recovery workflows

### Additional Features

- [ ] Terminal UI with charm.sh
- [ ] Cloud key provider integration
- [ ] Team key management
- [ ] Audit logging

## 🧪 Testing

### Running Tests

Tests are written using [bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

**Prerequisites:**

```bash
brew install bats-core
```

**Run tests:**

```bash
bun test
# or directly with bats
bats tests/*.bats
```

### Test Structure

- `tests/test_helper.bats` - Common test setup and teardown
- `tests/purr.bats` - Main test suite for purr functions

### Writing Tests

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on writing tests.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🔒 Security

For security-related issues, please see [SECURITY.md](SECURITY.md).

**Important Security Notes:**

- Never share your 1Password vault items or GPG keys
- Always run `purr lock` when finished to unload keys
- Review the script before sourcing it in your shell
- The script automatically obfuscates sensitive data in output

## 🐛 Troubleshooting

### 1Password Authentication Issues

If you see authentication errors:

1. Ensure 1Password desktop app is running and you're signed in
2. Run `op signin` to authenticate with the CLI
3. Check that 1Password CLI integration is enabled in preferences

### GPG Key Issues

If GPG keys aren't loading:

1. Verify the GPG key ID matches your actual key
2. Check that the passphrase is correct
3. Ensure the public and private keys are properly formatted in 1Password
4. Try running with `-v` flag for verbose output

### SSH Agent Issues

If SSH keys aren't available:

1. Ensure 1Password is running and SSH agent is enabled
2. Check that SSH keys are added to 1Password
3. Verify the SSH agent socket path (default: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`)

### GitHub Credentials Issues

If GitHub credentials aren't being set:

1. Verify the GitHub item exists in your 1Password vault
2. Check that the required fields (username, email, token) are present
3. GitHub setup is optional and won't fail if the item is missing

## 📚 Documentation

- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
