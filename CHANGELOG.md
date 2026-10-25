# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `purr` / `purr setup` is an idempotent machine setup: it detects an imported GPG secret key, Git `user.signingkey` / `commit.gpgsign` / `gpg.program`, an `IdentityAgent` in `~/.ssh/config`, and the GPG agent cache TTL, and it only contacts 1Password for what is still missing
- `purr check` is a local health check of the SSH agent, GPG key, Git signing, and GitHub auth. It signs a throwaway string only with `--pinentry-mode cancel`, so a missing passphrase cache does not prompt
- SSH setup writes the 1Password `IdentityAgent` into `~/.ssh/config` when no agent is configured there
- GitHub tokens prefer `gh auth token`. 1Password is the fallback, and a token already stored in `~/.cursor/mcp.json` is reused on later runs
- Failures name the step and include the underlying reason (`Failed: GPG key - ...`)

### Changed

- Each 1Password item is fetched once with `op item get --format json --reveal` instead of a separate `op item get --field` per value. A desktop-app connection failure is retried once
- `~/.cursor/mcp.json` is merged. Other MCP servers are preserved. `purr lock` removes only the GitHub server, and deletes the file when that was the only entry
- GPG agent TTL lines are updated in place. Other `gpg-agent.conf` settings are kept, and the agent is reloaded only when the TTL changes
- `purr lock` still signs out of the 1Password CLI, removes the signing secret key, clears Git signing, and unsets `GITHUB_TOKEN`. The `IdentityAgent` line in `~/.ssh/config` stays
- The startup banner no longer uses animated `lolcat`, so setup and check are not slowed by the animation

### Fixed

- Repeated 1Password desktop-app connections that made `purr` slow and could fail the last step with `1Password CLI couldn't connect to the 1Password desktop app` after earlier `op` calls had succeeded
- Direct execution is rejected from both zsh and bash, while sourcing from a lazy-load wrapper (`source` the file, then call `purr`) still defines the command

## [1.0.0] - 2025-01-20

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
