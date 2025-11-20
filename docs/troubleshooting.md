# Troubleshooting

Common issues and solutions when using purr.

## 1Password Issues

### "Failed to authenticate with 1Password CLI"

**Symptoms:**

- Error message when running `purr`
- 1Password CLI authentication fails

**Solutions:**

1. Ensure 1Password desktop app is running and you're signed in
2. Check that 1Password CLI integration is enabled:
   - Open 1Password
   - Go to Settings → Developer
   - Enable "Integrate with 1Password CLI"
3. Try authenticating manually:
   ```bash
   op signin
   ```
4. Ensure you have the latest version of 1Password CLI:
   ```bash
   brew upgrade --cask 1password-cli
   ```

### "No GPG key ID found in 1Password"

**Symptoms:**

- Error when loading GPG keys
- Cannot find GPG item in vault

**Solutions:**

1. Verify the item name matches `PURR_GPG_ITEM` (default: `gpg`)
2. Check that the vault name matches `PURR_VAULT_NAME` (default: `purr`)
3. Ensure the item has a `key_id` field
4. Try running with verbose mode:
   ```bash
   purr -v
   ```

### "Failed to retrieve public or private key from 1Password"

**Symptoms:**

- GPG key import fails
- Missing key data

**Solutions:**

1. Verify both `public_key` and `private_key` fields exist in the GPG item
2. Ensure keys are complete (include `-----BEGIN` and `-----END` lines)
3. Check for any formatting issues in the key fields

## SSH Issues

### "Failed to connect to 1Password SSH agent"

**Symptoms:**

- SSH keys not loading
- Cannot connect to SSH agent

**Solutions:**

1. Ensure 1Password is running
2. Verify SSH agent is enabled in 1Password:
   - Open 1Password
   - Go to Settings → Developer
   - Enable "Use the SSH agent"
3. Check the SSH agent socket path:
   ```bash
   echo $PURR_SSH_AUTH_SOCK
   ```
4. Verify the socket exists:
   ```bash
   test -S "$PURR_SSH_AUTH_SOCK" && echo "Socket exists" || echo "Socket not found"
   ```
5. Ensure SSH keys are added to 1Password

### "No identities available in the 1Password SSH agent"

**Symptoms:**

- SSH agent connected but no keys available

**Solutions:**

1. Add SSH keys to 1Password:
   - Open 1Password
   - Create a new item → SSH Key
   - Add your private SSH key
2. Enable the key in 1Password settings

## GPG Issues

### "GPG signing test failed"

**Symptoms:**

- GPG keys loaded but signing doesn't work
- Git commits fail to sign

**Solutions:**

1. Verify GPG key ID is correct:
   ```bash
   gpg --list-secret-keys
   ```
2. Check that the passphrase is correct in 1Password
3. Test GPG signing manually:
   ```bash
   echo "test" | gpg --clearsign
   ```
4. Verify Git configuration:
   ```bash
   git config --global user.signingkey
   git config --global commit.gpgsign
   ```
5. Try reloading keys:
   ```bash
   purr lock
   purr
   ```

### "GPG passphrase is not cached in the agent"

**Symptoms:**

- Frequent passphrase prompts
- GPG agent not caching passphrase

**Solutions:**

1. Check GPG agent configuration:
   ```bash
   cat ~/.gnupg/gpg-agent.conf
   ```
2. Restart GPG agent:
   ```bash
   gpgconf --kill gpg-agent
   gpg-agent --daemon
   ```
3. Try signing something to cache the passphrase:
   ```bash
   echo "test" | gpg --clearsign
   ```

## GitHub Issues

### "One or more GitHub credentials are missing"

**Symptoms:**

- GitHub credentials not configured
- Git user/email not set

**Solutions:**

1. Verify the GitHub item exists in your vault
2. Check that required fields are present:
   - username (or `user`, or `login`)
   - email (or `mail`, or `email address`)
   - pat/token (or `access token`, or `personal access token`)
3. Ensure field names match exactly (case-sensitive)
4. Note: GitHub setup is optional - this won't prevent purr from working

### "GITHUB_TOKEN not set"

**Symptoms:**

- GitHub token not available
- Tools requiring GITHUB_TOKEN fail

**Solutions:**

1. Run `purr` to load credentials
2. Verify the token is set:
   ```bash
   echo "${GITHUB_TOKEN:0:10}..."
   ```
3. Check that the GitHub item has a token/pat field

## General Issues

### Script fails with "should be sourced, not executed"

**Symptoms:**

- Error when trying to run purr.zsh directly

**Solutions:**

1. Source the script instead of executing it:
   ```zsh
   source ~/.zsh/purr/purr.zsh
   ```
2. Do not run it as: `./purr.zsh` or `zsh purr.zsh`

### Commands not found after installation

**Symptoms:**

- `purr` command not available
- "command not found" error

**Solutions:**

1. Ensure the script is sourced in your `~/.zshrc`:
   ```zsh
   source ~/.zsh/purr/purr.zsh
   ```
2. Reload your shell:
   ```bash
   source ~/.zshrc
   ```
3. Verify the path is correct

### Temporary files not cleaned up

**Symptoms:**

- Temporary GPG key files remain after use

**Solutions:**

1. This should not happen - cleanup is automatic
2. If you see temp files, report it as a bug
3. Manually clean up:
   ```bash
   rm -f /tmp/tmp.*
   ```

## Getting Help

If you're still experiencing issues:

1. Run with verbose mode:
   ```bash
   purr -v
   ```
2. Check status:
   ```bash
   purr check
   ```
3. Open an issue on GitHub with:
   - Error messages
   - Verbose output (with sensitive data redacted)
   - Your environment (macOS version, ZSH version)
   - Configuration (vault/item names if different from defaults)
