# GitHub Repository Setup Checklist

## ✅ Completed (Automated)
- [x] Issue templates (bug report, feature request, security)
- [x] Pull request template
- [x] CI workflow (GitHub Actions)
- [x] CODEOWNERS file
- [x] Release template

## 📋 Manual Steps Required

### 1. Repository Description & Topics
**Navigate to:** `Settings → General`

**Description:**
```
🐱 ZSH plugin for seamless key management with 1Password, SSH, and GPG. Load keys, configure Git signing, and manage GitHub credentials with a single command.
```

**Topics/Tags** (add these):
```
zsh
zsh-plugin
1password
gpg
ssh
key-management
security
git-signing
github
macos
developer-tools
shell-script
bats
automation
```

### 2. Repository Features
**Navigate to:** `Settings → General → Features`

- [x] **Issues** - Enable
- [ ] **Projects** - Optional (enable if you want GitHub Projects)
- [ ] **Discussions** - Optional (enable for community Q&A)
- [ ] **Wiki** - Disable (using docs/ folder instead)
- [ ] **Sponsorships** - Enable if you want GitHub Sponsors

### 3. Branch Protection Rules
**Navigate to:** `Settings → Branches → Add rule` (for `main` branch)

**Settings:**
- [x] Require a pull request before merging
  - [x] Require approvals: `1`
  - [x] Dismiss stale pull request approvals when new commits are pushed
- [x] Require status checks to pass before merging
  - [ ] Require branches to be up to date before merging
  - Select checks: `lint`, `test`, `format` (once CI is set up)
- [x] Require conversation resolution before merging (optional)
- [x] Do not allow bypassing the above settings

### 4. Labels Setup
**Navigate to:** `Issues → Labels → New label`

Create these labels:

| Name | Color | Description |
|------|-------|-------------|
| `bug` | `d73a4a` | Something isn't working |
| `enhancement` | `a2eeef` | New feature or request |
| `documentation` | `0075ca` | Documentation improvements |
| `question` | `d876e3` | Further information is requested |
| `help wanted` | `008672` | Extra attention is needed |
| `good first issue` | `7057ff` | Good for newcomers |
| `security` | `d73a4a` | Security vulnerability |
| `wontfix` | `ffffff` | This will not be worked on |
| `invalid` | `e4e669` | This doesn't seem right |
| `duplicate` | `cfd3d7` | This issue or pull request already exists |

### 5. GitHub Actions Settings
**Navigate to:** `Settings → Actions → General`

**Actions permissions:**
- [x] Allow all actions and reusable workflows
- [x] Allow actions to create and approve pull requests

**Workflow permissions:**
- [x] Read and write permissions
- [x] Allow GitHub Actions to create and approve pull requests

**Artifact and log retention:**
- [ ] Set to 30 days (default is 90)

### 6. Release Settings
**Navigate to:** `Settings → General → Releases`

- [ ] Enable "Auto-generate release notes"
- [ ] When creating a release, you can use `.github/RELEASE_TEMPLATE.md` as a template

### 7. Security Settings
**Navigate to:** `Settings → Security`

- [ ] Enable Dependabot alerts
- [ ] Enable Dependabot security updates (if applicable)
- [ ] Enable Secret scanning (if applicable)

### 8. Social Preview
**Navigate to:** `Settings → General → Social preview`

- [ ] Upload repository image (640×320px recommended)
- [ ] Or use default GitHub-generated image

### 9. Enable CI Workflow
**Navigate to:** `Actions` tab

- [ ] The CI workflow should appear automatically
- [ ] Run it manually or push a commit to trigger it
- [ ] Once it passes, enable it as a required check in branch protection

### 10. Verify Issue Templates
**Navigate to:** `Issues → New Issue`

- [ ] Verify all templates appear in the dropdown
- [ ] Test that blank issues are disabled (config.yml should handle this)

## 🎯 Quick Verification

Run this command to verify repository configuration:
```bash
gh repo view m3au/purr --json name,description,topics,isPrivate,hasIssuesEnabled,hasDiscussionsEnabled
```

## 📝 Notes

- All file-based configuration is already in place
- Most remaining steps are GUI-only settings in GitHub
- Branch protection can't be fully automated via files
- Labels can be added via GitHub CLI if you prefer:
  ```bash
  gh label create "bug" --description "Something isn't working" --color "d73a4a"
  gh label create "enhancement" --description "New feature or request" --color "a2eeef"
  # ... etc
  ```

## 🔗 Useful Links

- Repository: https://github.com/m3au/purr
- Actions: https://github.com/m3au/purr/actions
- Issues: https://github.com/m3au/purr/issues
- Settings: https://github.com/m3au/purr/settings

