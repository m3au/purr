# Security Policy

## Security Considerations

purr handles sensitive security materials including:

- SSH private keys
- GPG private keys
- GitHub credentials
- 1Password vault access

## Security Measures

1. **No Key Storage**

   - Keys are never stored locally
   - All keys are managed through 1Password
   - Keys are loaded into memory only when needed

2. **Secure Key Handling**

   - GPG keys are loaded directly into gpg-agent
   - SSH keys are managed by 1Password SSH agent
   - Passphrases are never written to disk

3. **Environment Protection**
   - Automatic key unloading with `purr lock`
   - Integration with system keychain
   - Memory-only operation

## Reporting a Vulnerability

If you discover a security vulnerability in purr, please follow these steps:

1. **Do Not** create a public GitHub issue
2. Send a private email to [m3au@pm.me](mailto:m3au@pm.me)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Best Practices

1. **Always Lock**

   ```bash
   purr lock
   ```

   before leaving your system unattended

2. **Check Status**

   ```bash
   purr check
   ```

   to verify key status regularly

3. **Use Verbose Mode**

   ```bash
   purr -v
   ```

   to see exactly what's happening

## Version Policy

- Security updates are released as soon as possible
- All security fixes are documented in release notes
- Breaking changes are clearly marked

## Key Management

1. **SSH Keys**

   - Managed through 1Password SSH agent
   - Never exposed to filesystem
   - Automatically unloaded on lock

2. **GPG Keys**

   - Protected by gpg-agent
   - Cache timeout configurable
   - Securely removed on lock

3. **Git Signing**
   - Uses GPG for commit signing
   - Keys managed through 1Password
   - Signing disabled on lock

## Security Don'ts

1. Do not store keys outside 1Password
2. Do not share your 1Password credentials
3. Do not leave keys loaded when not needed
4. Do not skip locking when stepping away

## Security Dos

1. Keep 1Password CLI updated
2. Use strong passphrases
3. Lock when not actively using keys
4. Check key status regularly
5. Monitor Git signing configuration

## License

This security policy and its contents are licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
