# Open Source Plan for purr

This document outlines the plan for preparing and publishing purr as an open source project on GitHub.

## Current Status

- ✅ Project moved to `packages/purr`
- ✅ Config files created (.gitignore, .markdownlint.json, .prettierrc, .shellcheckrc)
- ✅ package.json updated with correct file references
- ✅ Workspace file updated
- ✅ ~/.zshrc updated to point to new location

## Pre-Publication Checklist

### 1. Code Cleanup

- [ ] Remove any hardcoded personal information
- [ ] Review all 1Password vault references (currently "purr" vault)
- [ ] Ensure no sensitive data in comments or code
- [ ] Remove backup files (purr.zsh.backup)
- [ ] Add comprehensive inline documentation
- [ ] Review and clean up verbose logging statements

### 2. Documentation Updates

- [ ] Update README.md with:
  - [ ] Clear installation instructions
  - [ ] Prerequisites section (1Password CLI, GPG, SSH)
  - [ ] Configuration guide for 1Password vault structure
  - [ ] Troubleshooting section
  - [ ] Contributing guidelines
  - [ ] Code of conduct
  - [ ] Security considerations
- [ ] Add CHANGELOG.md
- [ ] Create CONTRIBUTING.md
- [ ] Add SECURITY.md for vulnerability reporting
- [ ] Create LICENSE file (MIT already exists)

### 3. 1Password Configuration Documentation

Create documentation for required 1Password items:

- [ ] Document required vault name (or make it configurable)
- [ ] Document required item structure:
  - [ ] "gpg" item with fields: key_id, password, public_key, private_key
  - [ ] "GitHub" item with fields: username, email, pat/token
- [ ] Add setup guide for 1Password integration
- [ ] Consider making vault name configurable via environment variable

### 4. Testing

- [ ] Create test suite using bats
- [ ] Add tests for:
  - [ ] Key loading functions
  - [ ] Key unloading functions
  - [ ] Status checking
  - [ ] Error handling
- [ ] Test on clean macOS environment
- [ ] Document test requirements

### 5. Security Review

- [ ] Review credential handling
- [ ] Ensure no credentials are logged
- [ ] Review temporary file handling
- [ ] Check for proper cleanup of sensitive data
- [ ] Review obfuscation function
- [ ] Add security best practices to documentation

### 6. GitHub Repository Setup

- [ ] Create GitHub repository (m3au/purr)
- [ ] Set up repository settings:
  - [ ] Enable Issues
  - [ ] Enable Discussions (optional)
  - [ ] Set up branch protection rules
  - [ ] Configure GitHub Actions (if needed)
- [ ] Add repository topics/tags
- [ ] Set up GitHub Pages (if needed for documentation)
- [ ] Configure Dependabot (if applicable)

### 7. CI/CD Setup

- [ ] Set up GitHub Actions for:
  - [ ] ShellCheck linting
  - [ ] Bats test execution
  - [ ] Prettier formatting checks
- [ ] Add status badges to README
- [ ] Set up release automation (optional)

### 8. Code Quality

- [ ] Run ShellCheck and fix all warnings
- [ ] Format all files with Prettier
- [ ] Ensure consistent code style
- [ ] Add function documentation
- [ ] Review error messages for clarity

### 9. Make Configurable

Consider making hardcoded values configurable:

- [ ] 1Password vault name (currently "purr")
- [ ] GPG item name (currently "gpg")
- [ ] GitHub item name (currently "GitHub")
- [ ] SSH agent socket path
- [ ] GPG agent cache TTL

Options:
- Environment variables
- Config file (~/.purrrc)
- Command-line flags

### 10. Feature Completeness

Review roadmap items:

- [ ] Decide which features to include in v1.0
- [ ] Document planned features in README
- [ ] Create GitHub issues for future enhancements
- [ ] Consider plugin architecture for other password managers

## Publication Steps

### Phase 1: Preparation (Week 1)

1. Complete code cleanup
2. Update all documentation
3. Create comprehensive test suite
4. Security review
5. Make vault/item names configurable

### Phase 2: Repository Setup (Week 1-2)

1. Create GitHub repository
2. Push code
3. Set up CI/CD
4. Configure repository settings
5. Add initial release tag (v1.0.0)

### Phase 3: Promotion (Week 2+)

1. Add to awesome-zsh-plugins list
2. Share on relevant communities:
   - r/zsh
   - r/1Password
   - Hacker News (Show HN)
   - Product Hunt (if applicable)
3. Write blog post (optional)
4. Share on Twitter/X
5. Submit to ZSH plugin managers

## Post-Publication Maintenance

- [ ] Set up issue templates
- [ ] Create release notes template
- [ ] Plan regular maintenance schedule
- [ ] Monitor for security issues
- [ ] Respond to issues and PRs
- [ ] Keep dependencies updated

## Configuration Recommendations

### Make Vault Name Configurable

```zsh
# In purr.zsh, add at the top:
PURR_VAULT_NAME="${PURR_VAULT_NAME:-purr}"
PURR_GPG_ITEM="${PURR_GPG_ITEM:-gpg}"
PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"
```

### Add Config File Support

Create `~/.purrrc`:
```zsh
# purr configuration
export PURR_VAULT_NAME="purr"
export PURR_GPG_ITEM="gpg"
export PURR_GITHUB_ITEM="GitHub"
```

## Security Considerations

1. **Never log credentials**: Ensure all credential output is obfuscated
2. **Temporary files**: Always clean up temp files, use secure temp directories
3. **Environment variables**: Clear sensitive env vars when locking
4. **1Password CLI**: Document security best practices for op CLI usage
5. **GPG key handling**: Ensure keys are properly removed on lock

## Documentation Structure

```
README.md          - Main documentation
CHANGELOG.md       - Version history
CONTRIBUTING.md    - Contribution guidelines
SECURITY.md        - Security policy
LICENSE            - MIT License
docs/
  setup.md         - Detailed setup guide
  configuration.md - Configuration options
  troubleshooting.md - Common issues
  development.md   - Development setup
```

## Success Metrics

- [ ] 10+ stars on GitHub
- [ ] Listed in awesome-zsh-plugins
- [ ] At least 5 users reporting successful usage
- [ ] No critical security issues
- [ ] Active issue/PR engagement

## Timeline

- **Week 1**: Code cleanup, documentation, testing
- **Week 2**: Repository setup, CI/CD, initial release
- **Week 3+**: Promotion, community engagement, maintenance

## Notes

- Keep the project focused on core functionality for v1.0
- Consider plugin architecture for future password manager support
- Maintain backward compatibility when possible
- Document all breaking changes in CHANGELOG

