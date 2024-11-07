# Development backlog

# Core Setup

- Fix duplicate reset.sh (system/ vs config/)
- Implement proper XDG paths for config, data, and cache
- Handle shell integration (zsh/bash sourcing, detection, reload)
- Add dev install mode with symlink-based installation
- Add uninstall cleanup
- Add config validation
- Implement config file load order (default → system → user)
- Create default config files (system and user)
- Add migration from ~/.purr
- Add OS and shell detection
- Add required tools check

# Testing

- Add test autowatch with file change detection
- Add test environment isolation
- Add test coverage reporting
- Complete core module tests (auth, config, git, gpg, ssh)
- Add integration tests (installation, key management, config)

# Security & Performance

- Implement secure cleanup for sensitive data
- Add key validation before loading
- Implement agent lifecycle management for SSH and GPG
- Add secure key unloading
- Add Git signing setup validation
- Add 1Password CLI detection and validation
- Track and optimize shell sourcing performance
- Track performance impacts
- Keep installation footprint minimal

# Features

- Add backup rotation/cleanup
- Add fancy output with lolcat (optional)
- Consider adding key rotation support
- Consider adding multiple key profiles

# Documentation

- Complete user guides (installation, configuration, key management)
- Add developer docs (architecture, modules, testing)
- Add shell completions (zsh, bash)
- Complete man pages (main, config, keys)

# Distribution

- Prepare Homebrew tap
- Create installation script for git-based distribution
- Add release automation
- Add checksum verification for updates
