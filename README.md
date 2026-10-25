# 🐱 purr

![purr](https://github.com/m3au/purr/blob/main/docs/purr.png)

[![CI](https://github.com/m3au/purr/workflows/CI/badge.svg)](https://github.com/m3au/purr/actions) [![License](https://img.shields.io/github/license/m3au/purr)](LICENSE) [![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![ZSH Plugin](https://img.shields.io/badge/ZSH-Plugin-blue)](https://github.com/unixorn/awesome-zsh-plugins) [![macOS](https://img.shields.io/badge/macOS-supported-success)](https://github.com/m3au/purr#prerequisites) [![1Password](https://img.shields.io/badge/1Password-integrated-blue)](https://1password.com/) [![GPG](https://img.shields.io/badge/GPG-enabled-brightgreen)](https://gnupg.org/) [![SSH](https://img.shields.io/badge/SSH-supported-yellow)](https://www.ssh.com/)

**purr** is a ZSH plugin that sets up 1Password SSH, GPG, and Git signing once on a machine. Run `purr` for that setup. Run `purr check` later to see whether SSH, GPG, Git signing, and GitHub are healthy, without calling 1Password for checks that can be done locally.

## 🚀 Features

- 🔐 **1Password only when something is missing** - Each item is read once as JSON, then reused
- 🔑 **Persistent SSH** - Writes the 1Password `IdentityAgent` into `~/.ssh/config` when it is absent
- 📝 **GPG & Git signing** - Imports a secret key only if it is not already on the keyring, then sets `user.signingkey`, `commit.gpgsign`, and `gpg.program`
- 🔄 **GitHub via `gh` first** - Uses `gh auth token` when the GitHub CLI is authenticated, and 1Password only as a fallback
- 🎯 **Cursor MCP** - Updates the GitHub server in `~/.cursor/mcp.json` and leaves other servers in place
- 🔍 **`purr check`** - Local health check of the SSH agent, GPG key, Git signing, and GitHub auth, plus a test signature that will not prompt
- 🔒 **`purr lock`** - Removes the signing key, clears Git signing, and signs out of the 1Password CLI

## 👥 Who is this for?

purr is designed for developers and teams who want a unified, automated solution for managing SSH keys, GPG keys, and Git signing. Perfect for:

- **1Password Users**: Developers already using 1Password for credential management who want to leverage it for SSH/GPG keys
- **Security-Conscious Teams**: Organizations requiring Git commit signing and secure key management practices
- **Daily Developers**: Developers who want setup to stick on the machine, and a quick `purr check` when something looks wrong
- **Team Leads**: Those setting up standardized development environments across team members
- **DevOps Engineers**: Professionals managing multiple machines who need consistent key management workflows
- **macOS Users**: Developers on macOS who need seamless integration with system tools and 1Password

### Use Cases

- **New machine setup**: Configure SSH, GPG, and Git signing once with `purr`
- **Health check**: Run `purr check` when a commit will not sign or SSH stops offering keys
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

   Or lazy-load it, which is what the script expects if `purr` is defined as a wrapper that sources this file and then calls `purr`:

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

Get from zero to productive in under 2 minutes:

### 1. Install purr

```bash
git clone https://github.com/m3au/purr.git ~/.zsh/purr
echo "source ~/.zsh/purr/purr.zsh" >> ~/.zshrc
source ~/.zshrc
```

### 2. Configure 1Password

Create a vault (default: `purr`) with GPG and GitHub items. See the [detailed setup guide](docs/setup.md) for step-by-step instructions.

### 3. Start using purr

```bash
purr        # One-time setup. Safe to run again; finished steps are skipped
purr check  # Local health check. Does not call 1Password
purr lock   # Remove the GPG signing key and sign out of the 1Password CLI
```

On a machine that is already configured, `purr` finishes without a 1Password prompt when `gh` is authenticated, or when git's user name and email are set and `~/.cursor/mcp.json` already has the GitHub token.

## 🔑 Usage

### Implemented Commands

- `purr` or `purr setup` - Idempotent setup for this machine
- `purr check` - Local health check (exit 1 when SSH, GPG, or Git signing is not ready)
- `purr lock` - Remove the GPG signing key, clear Git signing, and sign out of the 1Password CLI
- `purr -v` - Verbose mode, including how many 1Password item reads the command made
- `purr -h` - Shows help message

### Common Workflows

#### New machine, then leave it alone

```bash
# Once: write SSH config, import GPG if needed, set Git signing, configure GitHub
purr

# Later, in any shell: confirm the persistent setup still works
purr check

# Commits are signed from the local keyring. New shells do not need `purr`.
git commit -m "Your commit message"
```

`purr check` reports each step as `ok`, `warn`, or `fail`. Warnings (for example a GPG passphrase that is not cached, or GitHub auth that is not configured) still exit 0. A failed SSH agent, missing secret key, or incomplete Git signing config exits 1.

```bash
purr check
```

```text
purr check
  SSH config       ok    IdentityAgent points at the 1Password socket
  SSH agent        ok    2 identities
  GPG key          ok    ABCD********WXYZ is in the secret keyring
  Git signing      ok    gpgsign=true program=/opt/homebrew/bin/gpg
  GPG cache        ok    TTL 34560000
  Test signature   ok    signed a throwaway string without prompting
  GitHub           ok    authenticated via gh

All checks passed.
```

The test signature uses `--pinentry-mode cancel`. If the passphrase is not cached, the check says so and does not open a passphrase prompt.

#### Setting Up a New Machine

```bash
# Install purr
git clone https://github.com/m3au/purr.git ~/.zsh/purr
echo "source ~/.zsh/purr/purr.zsh" >> ~/.zshrc

# Configure 1Password vault with GPG and GitHub items
# (see docs/setup.md for details)

# Set up this machine
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

#### Example 1: First setup

```bash
$ purr
ᓚᘏᗢ purr setup
  SSH config       set   added IdentityAgent to ~/.ssh/config
  SSH agent        ok    2 identities
  GPG cache        set   set cache TTL to 34560000
  GPG key          set   imported secret key ABCD********WXYZ from 1Password
  Git signing      set   signing key ABCD********WXYZ, gpg.program /opt/homebrew/bin/gpg
  GitHub           ok    token from gh; git user your-name
  Cursor MCP       set   updated the github server in ~/.cursor/mcp.json

ᓚᘏᗢ purr
```

Run `purr` again on that machine and the same steps report `ok` without contacting 1Password.

#### Example 2: A 1Password failure names the step

```text
Failed: GPG key - could not read 1Password item 'gpg' in vault 'purr': 1Password CLI couldn't connect to the 1Password desktop app
Setup incomplete.
```

purr reads the GPG item once (`op item get --format json --reveal`) and retries that read once if the desktop app connection fails. It does not call `op` again for `key_id`, `password`, `public_key`, and `private_key`.

#### Example 3: Locking keys

```bash
$ purr lock
  1Password        ok    signed out of the CLI
  SSH agent        ok    unset SSH_AUTH_SOCK; IdentityAgent in ~/.ssh/config kept
  GPG key          set   removed secret key ABCD********WXYZ
  Git signing      ok    cleared user.signingkey and commit.gpgsign
  GitHub           set   removed the GitHub server from ~/.cursor/mcp.json
System locked
ᓚᘏᗢ hiss
```

The `IdentityAgent` line stays in `~/.ssh/config`. The next `purr` imports the GPG key from 1Password again because `purr lock` removed it from the keyring. Other MCP servers in `~/.cursor/mcp.json` are kept. If the GitHub server was the only entry, the file is removed. An invalid `mcp.json` is left untouched.

### GitHub Token Management

`purr` resolves a GitHub token in this order:

1. `gh auth token`, when the GitHub CLI is installed and authenticated
2. `GITHUB_TOKEN` already exported in this shell
3. The token already stored on the `github` server in `~/.cursor/mcp.json`
4. One 1Password read of the GitHub item (`PURR_GITHUB_ITEM` in `PURR_VAULT_NAME`)

Git `user.name` and `user.email` are filled only when they are empty. A token from 1Password is also stored with `git credential-osxkeychain` when that helper exists. `purr lock` unsets `GITHUB_TOKEN`.

### Current Implementation

The default `purr` command:

- Detects an existing `IdentityAgent`, GPG secret key, Git signing config, and GPG agent cache TTL
- Contacts 1Password only for a missing GPG key or a missing GitHub token
- Reads each 1Password item once and reuses the JSON
- Prefers `gh auth token` over the GitHub item in 1Password

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

purr includes a comprehensive test suite using [bats](https://github.com/bats-core/bats-core). Run tests quickly:

```bash
brew install bats-core  # One-time setup
bun test                # Run all tests (~7 seconds)
bun run test:unit       # Run unit tests only (~2 seconds)
```

### Test Structure

Tests are written using [bats](https://github.com/bats-core/bats-core). The test structure includes:

- `tests/test_helper.bats` - Common test setup and teardown
- `tests/purr.bats` - Main test suite for purr functions
- `tests/unit_obfuscate.bats` - Unit tests for obfuscate_key function
- `tests/mocks/` - Mock scripts for external commands (op, gpg, git, ssh)

### Writing Tests

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on writing tests.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🔒 Security

For security-related issues, please see [SECURITY.md](SECURITY.md).

**Important Security Notes:**

- Never share your 1Password vault items or GPG keys
- Run `purr lock` when you want the GPG secret key removed and the 1Password CLI signed out. SSH keeps using the agent socket named in `~/.ssh/config` while 1Password is unlocked
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

1. Ensure 1Password is running and the SSH agent is enabled
2. Check that SSH keys are added to 1Password
3. Confirm `~/.ssh/config` has an `IdentityAgent` pointing at the 1Password socket. `purr` adds one when it is missing and leaves a different `IdentityAgent` alone
4. Verify the socket path (default: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`), or run `purr check`

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
