# 🐱 purr

[![purr](https://github.com/m3au/store/blob/main/docs/purr.png)]

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/m3au/purr)](https://github.com/m3au/purr/releases)
[![License](https://img.shields.io/github/license/m3au/purr)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/m3au/purr)](https://github.com/m3au/purr/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/m3au/purr)](https://github.com/m3au/purr/pulls)
[![Tests](https://github.com/m3au/purr/workflows/Tests/badge.svg)](https://github.com/m3au/purr/actions)
[![CodeQL](https://github.com/m3au/purr/workflows/CodeQL/badge.svg)](https://github.com/m3au/purr/security/code-scanning)
[![Maintainability](https://api.codeclimate.com/v1/badges/YOUR_REPO_ID/maintainability)](https://codeclimate.com/github/m3au/purr)
[![codecov](https://codecov.io/gh/m3au/purr/branch/main/graph/badge.svg)](https://codecov.io/gh/m3au/purr)
[![ZSH Plugin](https://img.shields.io/badge/ZSH-Plugin-blue)](https://github.com/unixorn/awesome-zsh-plugins)
[![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Maintenance](https://img.shields.io/maintenance/yes/2024)](https://github.com/m3au/purr/graphs/commit-activity)
[![Last Commit](https://img.shields.io/github/last-commit/m3au/purr)](https://github.com/m3au/purr/commits/main)
[![npm version](https://img.shields.io/npm/v/@m3au/purr)](https://www.npmjs.com/package/@m3au/purr)
[![npm downloads](https://img.shields.io/npm/dm/@m3au/purr)](https://www.npmjs.com/package/@m3au/purr)
[![DeepSource](https://deepsource.io/gh/m3au/purr.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/m3au/purr/?ref=repository-badge)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/YOUR_PROJECT_ID)](https://www.codacy.com/gh/m3au/purr/dashboard)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=m3au_purr&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=m3au_purr)
[![Twitter Follow](https://img.shields.io/twitter/follow/m3au?style=social)](https://twitter.com/m3au)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/m3au?style=social)](https://github.com/sponsors/m3au)
[![Reddit User Karma](https://img.shields.io/reddit/user-karma/combined/m3au?style=social)](https://reddit.com/u/m3au)
[![macOS](https://img.shields.io/badge/macOS-supported-success)](https://github.com/m3au/purr#prerequisites)
[![1Password](https://img.shields.io/badge/1Password-integrated-blue)](https://1password.com/)
[![GPG](https://img.shields.io/badge/GPG-enabled-brightgreen)](https://gnupg.org/)
[![SSH](https://img.shields.io/badge/SSH-supported-yellow)](https://www.ssh.com/)

A ZSH plugin for seamless key management that integrates 1Password, SSH, and GPG. Securely loads and unloads keys, configures Git signing, and manages GitHub credentials - all with a simple purr command.

## 🚀 Features

- 🔐 Seamless integration with 1Password for secure key storage
- 🔑 Automated SSH key management
- 📝 GPG key handling and Git commit signing
- 🔄 GitHub credentials configuration
- 🔒 Secure key unloading with lock command
- 🔍 Key status checking capabilities

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

### Using a ZSH plugin manager

#### [antidote](https://github.com/mattmc3/antidote)

### Manual installation

1. Clone the repository
2. Source the init script in your ZSH configuration (e.g., `~/.zshrc`):

   ```zsh
   source path/to/purr/init.zsh
   ```

3. Add the plugin to your ZSH plugins list:

   ```zsh
   antidote bundle <path-to-purr>
   ```

## 🔑 Usage

### Implemented Commands

- `purr` - Loads keys and configures Git signing
- `purr lock` - Unloads keys and locks 1Password
- `purr check` - Checks key status
- `purr -v` - Verbose mode for any command
- `purr -h` - Shows help message

### Coming Soon

- `purr github` - Configures GitHub credentials
- `purr git` - Configures Git signing
- `purr gpg` - Manages GPG keys
- `purr ssh` - Manages SSH keys
- `purr 1password` - Manages 1Password integration
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

```bash
bun test
```


## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

