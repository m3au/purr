# 🐱 purr

![purr](https://github.com/m3au/store/blob/main/docs/purr.png)

[![License](https://img.shields.io/github/license/m3au/purr)](LICENSE)
[![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![ZSH Plugin](https://img.shields.io/badge/ZSH-Plugin-blue)](https://github.com/unixorn/awesome-zsh-plugins)
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
