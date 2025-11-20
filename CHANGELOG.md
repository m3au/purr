# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Configuration via environment variables for vault and item names
- Comprehensive documentation (SECURITY.md, CONTRIBUTING.md, CHANGELOG.md)
- Improved README with installation and configuration instructions
- GitHub credentials setup integration in main `purr` command

### Changed
- 1Password vault name is now configurable via `PURR_VAULT_NAME` environment variable
- GPG item name is now configurable via `PURR_GPG_ITEM` environment variable
- GitHub item name is now configurable via `PURR_GITHUB_ITEM` environment variable

### Fixed
- Missing call to `setup_github_credentials()` in main function

## [1.0.0] - 2025-01-XX

### Added
- Initial release
- 1Password integration for secure key storage
- SSH key management via 1Password SSH agent
- GPG key management with Git commit signing
- GitHub credentials configuration
- Key status checking (`purr check`)
- Secure key unloading (`purr lock`)
- Key obfuscation for secure output
- GitHub token configuration for Cursor MCP servers

[Unreleased]: https://github.com/m3au/purr/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/m3au/purr/releases/tag/v1.0.0

