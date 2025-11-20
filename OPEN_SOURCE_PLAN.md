# Open Source Plan for purr

This document outlines the plan for preparing and publishing purr as an open source project on GitHub.

## Current Status

- ✅ Project moved to `packages/purr`
- ✅ Config files created (.gitignore, .markdownlint.json, .prettierrc, .shellcheckrc)
- ✅ package.json updated with correct file references
- ✅ Workspace file updated
- ✅ ~/.zshrc updated to point to new location
- ✅ **Repository published to GitHub as public repo (m3au/purr)**
- ✅ **v1.0.0 release created and tagged**
- ✅ **All major open source preparation tasks completed**

## Pre-Publication Checklist

### 1. Code Cleanup

- [x] Remove any hardcoded personal information
- [x] Review all 1Password vault references (now configurable via PURR_VAULT_NAME)
- [x] Ensure no sensitive data in comments or code
- [x] Remove backup files (purr.zsh.backup)
- [x] Add comprehensive inline documentation
- [x] Review and clean up verbose logging statements
- [x] Fix all ShellCheck warnings (shebang, quoting, variable declarations)

### 2. Documentation Updates

- [x] Update README.md with:
  - [x] Clear installation instructions
  - [x] Prerequisites section (1Password CLI, GPG, SSH)
  - [x] Configuration guide for 1Password vault structure
  - [x] Troubleshooting section
  - [x] Contributing guidelines
  - [x] Code of conduct reference
  - [x] Security considerations
- [x] Add CHANGELOG.md
- [x] Create CONTRIBUTING.md
- [x] Add SECURITY.md for vulnerability reporting
- [x] Create LICENSE file (MIT already exists)
- [x] Create CODE_OF_CONDUCT.md
- [x] Create docs/ directory with setup.md, configuration.md, troubleshooting.md, development.md

### 3. 1Password Configuration Documentation

Create documentation for required 1Password items:

- [x] Document required vault name (now configurable via PURR_VAULT_NAME)
- [x] Document required item structure:
  - [x] "gpg" item with fields: key_id, password, public_key, private_key
  - [x] "GitHub" item with fields: username, email, pat/token
- [x] Add setup guide for 1Password integration (docs/setup.md)
- [x] Make vault name configurable via environment variable

### 4. Testing

- [x] Create test suite using bats (tests/ directory with test_helper.bats and purr.bats)
- [x] Add tests for:
  - [x] Key loading functions (test framework in place)
  - [x] Key unloading functions (test framework in place)
  - [x] Status checking (test framework in place)
  - [x] Error handling (test framework in place)
- [ ] Test on clean macOS environment (manual step)
- [x] Document test requirements (README.md and CONTRIBUTING.md)

### 5. Security Review

- [x] Review credential handling (all credentials obfuscated)
- [x] Ensure no credentials are logged (verified all outputs use obfuscate_key)
- [x] Review temporary file handling (trap handlers added for cleanup)
- [x] Check for proper cleanup of sensitive data (cleanup guaranteed via traps)
- [x] Review obfuscation function (verified secure)
- [x] Add security best practices to documentation (SECURITY.md updated)

### 6. GitHub Repository Setup

- [x] Create GitHub repository (m3au/purr) - ✅ PUBLIC REPO CREATED
- [x] Set up repository settings:
  - [x] Enable Issues (via templates)
  - [ ] Enable Discussions (optional - can be enabled later)
  - [ ] Set up branch protection rules (can be configured in GitHub UI)
  - [x] Configure GitHub Actions (CI workflow created)
- [x] Add repository topics/tags (zsh, plugin, 1password, gpg, ssh, key-management, security)
- [ ] Set up GitHub Pages (optional - not needed at this time)
- [ ] Configure Dependabot (if applicable - not needed for this project)

### 7. CI/CD Setup

- [x] Set up GitHub Actions for:
  - [x] ShellCheck linting (.github/workflows/ci.yml)
  - [x] Bats test execution (.github/workflows/ci.yml)
  - [x] Prettier formatting checks (.github/workflows/ci.yml)
- [x] Add status badges to README (CI badge added)
- [ ] Set up release automation (optional - can be added later)

### 8. Code Quality

- [x] Run ShellCheck and fix all warnings (all critical warnings fixed)
- [x] Format all files with Prettier (via CI workflow)
- [x] Ensure consistent code style (documented in CONTRIBUTING.md)
- [x] Add function documentation (all functions documented)
- [x] Review error messages for clarity (error messages reviewed)

### 9. Make Configurable

Consider making hardcoded values configurable:

- [x] 1Password vault name (configurable via PURR_VAULT_NAME)
- [x] GPG item name (configurable via PURR_GPG_ITEM)
- [x] GitHub item name (configurable via PURR_GITHUB_ITEM)
- [x] SSH agent socket path (configurable via PURR_SSH_AUTH_SOCK)
- [x] GPG agent cache TTL (configurable via PURR_GPG_CACHE_TTL)

Options:
- [x] Environment variables (all options implemented)
- [x] Config file (~/.purrrc) (implemented)
- [ ] Command-line flags (not implemented - environment variables preferred)

### 10. Feature Completeness

Review roadmap items:

- [x] Decide which features to include in v1.0 (core features included)
- [x] Document planned features in README (roadmap section)
- [ ] Create GitHub issues for future enhancements (can be done as needed)
- [ ] Consider plugin architecture for other password managers (future work)

## Publication Steps

### Phase 1: Preparation (Week 1)

1. Complete code cleanup
2. Update all documentation
3. Create comprehensive test suite
4. Security review
5. Make vault/item names configurable

### Phase 2: Repository Setup (Week 1-2)

1. ✅ Create GitHub repository - COMPLETED
2. ✅ Push code - COMPLETED
3. ✅ Set up CI/CD - COMPLETED (.github/workflows/ci.yml)
4. ✅ Configure repository settings - COMPLETED (issue templates, topics)
5. ✅ Add initial release tag (v1.0.0) - COMPLETED

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

- [x] Set up issue templates (.github/ISSUE_TEMPLATE/)
- [ ] Create release notes template (can be added to .github/RELEASE_TEMPLATE.md)
- [ ] Plan regular maintenance schedule (ongoing)
- [ ] Monitor for security issues (ongoing)
- [ ] Respond to issues and PRs (ongoing)
- [ ] Keep dependencies updated (ongoing)

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

