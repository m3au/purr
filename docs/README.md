# purr <!-- omit in toc -->

A lightweight shell utility that integrates 1Password, SSH, and GPG key management. Securely loads and unloads keys, configures Git signing, and manages GitHub credentials - all with a simple purr command.

> **Target Audience**: purr is designed for macOS and Unix-like systems. It relies heavily on Unix shell features, 1Password CLI integration, and native SSH/GPG functionality for security and efficiency. Windows users should consider using WSL2 (Windows Subsystem for Linux) or similar Unix-like environments.

![purr](https://github.com/m3au/store/blob/main/docs/purr.png)
- [Features](#features)
- [Usage](#usage)
- [Installation](#installation)
- [Setup](#setup)
- [Contributing](#contributing)
- [License](#license)
- [next](#next)
  - [Manual Test Steps](#manual-test-steps)

## Features

- One-command setup for secure development environment
- Touch ID integration for:
  - SSH authentication (Git operations, remote access)
  - GPG operations (commit signing)
  - Terminal commands (sudo)
- Automated key management through 1Password
- Secure key unloading when stepping away

## Usage

For complete command reference and examples, see the [Usage Guide](docs/guides/usage/README.md).

Morning Setup:

   ```bash
   purr  # Load everything at once

   # Connects to 1Password SSH agent
   # Loads GPG keys
   # Configures Git signing
   # Sets up GitHub credentials
   ```

During Development:

- Make signed Git commits (Touch ID prompt)
- Use SSH with Touch ID authentication
- Check key status: `purr check`
- View detailed status: `purr -v check`

End of Day:

   ```bash
   purr lock  # Unload everything securely
   ```

purr is designed with security in mind:

- No local key storage - everything stays in 1Password
- Memory-only operations
- Touch ID authentication for sensitsive operations
- Easy key unloading / locking

For detailed security information and best practices, see our [Security Policy](docs/SECURITY.md).

## Installation

For detailed setup instructions and requirements, see the [Setup Guide](docs/guides/setup/README.md).

### Via Homebrew (Recommended) <!-- omit in toc -->
```bash
brew install m3au/tap/purr
```

### Manual Installation <!-- omit in toc -->
```bash
curl -fsSL https://raw.githubusercontent.com/m3au/purr/main/install | bash
```

## Setup

### GitHub Configuration <!-- omit in toc -->

1. Create a new Personal Access Token (Classic):
   - Go to GitHub Settings → Developer Settings → [Personal Access Tokens (Classic)](https://github.com/settings/tokens)
   - Click "Generate new token (classic)"
   - Name it something like "purr-cli"
   - Select the required scopes:
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)
     - `write:packages` (Upload packages)
     - `delete:packages` (Delete packages)
     - `admin:gpg_key` (Manage GPG keys)
   - Click "Generate token"
   - **Important**: Copy your token immediately - you won't be able to see it again!

### 1Password Configuration <!-- omit in toc -->

1. Create a dedicated vault in 1Password:
   - Open 1Password
   - Click "Add Vault" (+ icon)
   - Name it "purr" (or set custom name via `PURR_VAULT` environment variable)

2. In the "purr" vault, create three items:

   a. Create a new "Login" item named "gpg":
   - Title: `gpg`
   - Add custom fields:
     - `key_id`: Your GPG key ID (e.g., "819B065CAC953C07E834B416121EEAD62DC2067B")
     - `password`: Your GPG key password
     - `public_key`: Your full GPG public key (including BEGIN/END blocks)
     - `private_key`: Your full GPG private key (including BEGIN/END blocks)

   b. Create a new "Login" item named "github":
   - Title: `github`
   - Add custom fields:
     - `username`: Your GitHub username
     - `email`: Your GitHub email
     - `pat`: Your GitHub Personal Access Token

   c. Create a new "Login" item named "ssh":
   - Title: `ssh`
   - Add custom fields:
     - `public_key`: Your SSH public key
     - `private_key`: Your SSH private key
     - `password`: Your SSH key password (if any)
     - `key_type`: The key type (e.g., "Ed25519")
     - `fingerprint`: The key fingerprint

You can use custom field names by setting the `PURR_` variables in your shell config.

For detailed configuration options and advanced setup, see the [Setup Guide](docs/guides/setup/README.md).

### Touch ID Configuration <!-- omit in toc -->

1. Enable Touch ID for terminal commands:

   ```bash
   sudo sh -c 'echo "auth sufficient pam_tid.so" >> /etc/pam.d/sudo'
   ```

2. Install and configure pinentry for GPG Touch ID support:

   ```bash
   brew install pinentry-mac
   echo "pinentry-program $(which pinentry-mac)" > ~/.gnupg/gpg-agent.conf
   chmod 700 ~/.gnupg
   gpgconf --kill gpg-agent
   ```

3. Configure your terminal:
   - **iTerm2**: Preferences → Advanced → Enable "Allow Touch ID authentication"
   - **Terminal.app**: Works out of the box
   - **VS Code**: Settings → Search for "terminal.integrated.enableTouchId" → Enable

## Contributing

We'd love your help making purr better! We're a friendly community that welcomes contributions of all kinds:

- Found a bug? Open an issue or PM us
- Have a feature request? We'd love to hear it
- Want to improve docs? Yes please!
- Got a fix ready? PRs welcome

Not sure where to start? Feel free to:

- [Open an issue](https://github.com/m3au/purr/issues/new)
- [Send us a PM](mailto:m3au@pm.me)
- Join our discussions

Every contribution helps, and we aim to review all PRs promptly!

Check out our [Development Guide](docs/guides/development/README.md).

## License

MIT - See [LICENSE](LICENSE)

## next

### Manual Test Steps
1. Clean Development Environment:
   ```bash
   # Clean build artifacts
   make clean
   # Should remove tests/dev and dist directories

   # Deep clean (including dependencies)
   make deep-clean
   # Should uninstall development tools
   ```

2. Setup Development Environment:
   ```bash
   # Install dependencies and create directories
   make setup
   # Should install: shellcheck, shfmt, kcov, go-md2man
   # Should create: tests/dev/, dist/
   ```

3. Generate Documentation:
   ```bash
   # Generate man pages
   make man
   # Should create: dist/man/purr.1

   # Generate completions
   make completions
   # Should create: dist/completion/{completion.zsh,completion.bash}

   # Generate AI docs
   make background context
   # Should create: docs/{background.md,context.md}
   ```

4. Run Tests:
   ```bash
   # Run all tests
   make test
   # Should run script and core tests

   # Run with coverage
   make coverage
   # Should create: tests/dev/coverage/index.html
   ```

5. Release Process:
   ```bash
   # Create distribution
   make dist
   # Should create: dist/purr-VERSION.tar.gz

   # Test distribution
   make test-dist
   # Should create: tests/dev/dist/purr-test.tar.gz

   # Publish release
   make release-patch  # or release-minor, release-major
   # Should update version and create release
   ```

- [ ] add kcov to Makefile back
- [ ] add man page generation to Makefile
- [ ] add coverage reporting to Makefile
- [ ] add linting to Makefile
- [ ] add formatting to Makefile
- [ ] add docs to Makefile
- [ ] add install docs to README
- [ ] add setup docs to README
- [ ] add usage docs to README
- [ ] add security docs to README
- [ ] add development docs to README
- [ ] add testing docs to README
- [ ] add Makefile docs to README
- [ ] add dist to gitignore?
