# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in purr, please follow these steps:

1. **Do NOT** open a public GitHub issue for the vulnerability.
2. Email the details to: **m3au@pm.me**
3. Include the following information:
   - A description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Suggested fix (if any)

We will respond to your report within 48 hours and work with you to address the issue before making it public.

## Security Best Practices

When using purr, please follow these security best practices:

### 1Password CLI Security

- Keep your 1Password CLI (`op`) updated to the latest version
- Ensure 1Password desktop app is running and you're signed in before using purr
- Use strong master passwords for your 1Password vault
- Enable 1Password's biometric authentication when available

### GPG Key Security

- Never share your GPG private keys
- Store GPG keys securely in 1Password
- Use strong passphrases for your GPG keys
- Regularly rotate GPG keys (annually recommended)

### SSH Key Security

- Use 1Password's built-in SSH agent for key management
- Never expose SSH private keys in plain text
- Regularly audit and rotate SSH keys

### GitHub Token Security

- Use GitHub Personal Access Tokens (PAT) with minimal required scopes
- Store tokens securely in 1Password
- Regularly rotate GitHub tokens
- Use fine-grained personal access tokens when possible

### General Security

- **Never log credentials**: The script uses obfuscation to hide sensitive data in output
- **Clean up temporary files**: The script automatically removes temporary files containing keys
- **Lock when done**: Always run `purr lock` when finished to unload keys and lock 1Password
- **Environment variables**: The `GITHUB_TOKEN` environment variable is unset when locking
- **Review code**: Review any modifications to the script before sourcing it

## Known Security Considerations

1. **Temporary Files**: GPG keys are temporarily written to disk during import. These files are deleted immediately after use and cleanup is guaranteed via trap handlers even on error. However, this is still a potential security risk if the system is compromised during execution. Temporary files are created in the system temporary directory using `mktemp`, which provides secure file permissions (0600) by default.

   - All temporary files are cleaned up with `rm -f` after use
   - Trap handlers ensure cleanup on EXIT, INT, and TERM signals
   - Passphrase files used for GPG testing are also cleaned up

2. **Environment Variables**: The `GITHUB_TOKEN` is stored as an environment variable and may be visible in process lists. This variable is automatically unset when running `purr lock`. 

   - Consider the security implications of environment variables in process lists
   - Environment variables are cleared when locking keys via `purr lock`

3. **1Password CLI**: This script relies on 1Password CLI authentication. Ensure you follow 1Password's security best practices.

   - Keep 1Password CLI updated to the latest version
   - Use biometric authentication when available
   - Lock 1Password when not in use

4. **GPG Agent Cache**: The script configures a long GPG agent cache TTL (default: 34560000 seconds = ~400 days). This means passphrases remain cached for an extended period. You can configure a shorter TTL via the `PURR_GPG_CACHE_TTL` environment variable.

   - Default TTL is very long to avoid repeated passphrase prompts
   - Consider setting a shorter TTL for enhanced security
   - Configure via: `export PURR_GPG_CACHE_TTL=3600` (1 hour)
   - The cache is cleared when running `purr lock`

## Responsible Disclosure

We follow responsible disclosure practices:

- We will acknowledge receipt of your vulnerability report
- We will provide a timeline for addressing the vulnerability
- We will notify you when the vulnerability is fixed
- We will credit you in our security advisories (unless you prefer to remain anonymous)

Thank you for helping keep purr and its users safe!

