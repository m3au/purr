# Usage Guide

## Basic Commands

### Load Keys

```bash
purr
```

- Launches 1Password if not running
- Authenticates with 1Password
- Loads SSH and GPG keys
- Configures Git signing
- Sets up GitHub credentials

### Key Management

```bash
# List loaded keys
purr keys list

# Load a specific key
purr keys load github.ssh

# Unload a specific key
purr keys unload github.ssh
```

### Check Status

```bash
# Show overall status
purr status

# List loaded keys
purr status --keys

# Show detailed status
purr status --debug

# Check key status
purr status --check
```

### Lock Everything

```bash
purr lock
```

- Unloads SSH keys
- Unloads GPG keys
- Signs out of 1Password
- Disables Git signing

## Configuration

### View Configuration

```bash
# List all settings
purr config list

# Get specific setting
purr config get PURR_VAULT
```

### Modify Configuration

```bash
# Set configuration value
purr config set PURR_VAULT my-vault

# Reset to defaults
purr config reset
```

### Backup Configuration

```bash
# Create backup
purr backup

# List backups
ls ~/.purr/backups
```

## System Management

### Installation

```bash
# Install purr
purr install

# Verify installation
purr verify

# Update to latest version
purr update
```

### Troubleshooting

```bash
# Run diagnostics
purr doctor

# Show version info
purr version
```

### System Diagnostics

```bash
# Run diagnostics
purr doctor

# Show version info
purr version
```

## Options

### Verbose Mode

```bash
purr -v
purr --verbose
```

Shows detailed output including:

- Key loading process
- Agent connections
- Configuration changes
- Operation results

### Help

```bash
purr -h
purr --help
```

Shows usage information and available commands.

## Examples

1. Load keys with verbose output:

   ```bash
   purr -v
   ```

2. Check status quietly:

   ```bash
   purr status
   ```

3. Lock with confirmation:

   ```bash
   purr -v lock
   ```

## Environment Variables

- `PURR_VAULT`: 1Password vault name (default: purr)
- `PURR_GPG_ITEM`: GPG key item name (default: purr gpg)
- `PURR_GITHUB_ITEM`: GitHub credentials item name (default: GitHub)
