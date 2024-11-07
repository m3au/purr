# Development Roadmap

## 1. Core Installation Flow

- [ ] Fix duplicate reset.sh (system/ vs config/)
- [ ] Implement proper XDG paths
  - [ ] Config: ${XDG_CONFIG_HOME:-$HOME/.config}/purr
  - [ ] Data: ${XDG_DATA_HOME:-$HOME/.local/share}/purr
  - [ ] Cache: ${XDG_CACHE_HOME:-$HOME/.cache}/purr
- [ ] Shell integration
  - [ ] Handle zsh sourcing
  - [ ] Handle bash sourcing
  - [ ] Auto-detect shell type
  - [ ] Add shell reload detection
- [ ] Development environment
  - [ ] Add dev install mode
  - [ ] Add symlink-based installation
  - [ ] Add uninstall cleanup

## 2. Testing Infrastructure

- [ ] Complete core module tests
  - [ ] auth.spec
  - [ ] config.spec
  - [ ] git.spec
  - [ ] gpg.spec
  - [ ] ssh.spec
- [ ] Add test autowatch
  - [ ] File change detection
  - [ ] Auto-run relevant tests
  - [ ] Test environment isolation
- [ ] Add test coverage reporting
- [ ] Add integration tests
  - [ ] Full installation flow
  - [ ] Key management cycle
  - [ ] Config management

## 3. Key Management

- [ ] SSH Integration
  - [ ] Agent lifecycle management
  - [ ] Key loading validation
  - [ ] Secure key unloading
- [ ] GPG Integration
  - [ ] Agent lifecycle management
  - [ ] Key validation
  - [ ] Git signing setup
- [ ] 1Password Integration
  - [ ] CLI detection
  - [ ] Authentication flow
  - [ ] Item access validation

## 4. Configuration

- [ ] Config Files
  - [ ] purr.conf.default (system)
  - [ ] user.conf.default (user)
- [ ] Config Management
  - [ ] Load order: default → system → user
  - [ ] Config validation
  - [ ] Migration from ~/.purr
- [ ] Environment Detection
  - [ ] OS detection
  - [ ] Shell detection
  - [ ] Required tools check

## 5. Documentation

- [ ] User Guides
  - [ ] Installation guide
  - [ ] Configuration guide
  - [ ] Key management guide
- [ ] Developer Docs
  - [ ] Architecture overview
  - [ ] Module documentation
  - [ ] Test documentation
- [ ] Shell Completions
  - [ ] zsh completion
  - [ ] bash completion
- [ ] Man Pages
  - [ ] purr.1 main page
  - [ ] purr-config.1
  - [ ] purr-keys.1

## Notes

- Remember to maintain test coverage while developing
- Keep security as top priority
- Document all shell compatibility issues
- Track performance impacts
- Keep installation footprint minimal

## Dependencies

Required:

- 1Password CLI (op)
- SSH
- GPG
- Git

Optional:

- lolcat (for fancy output)
- shellcheck (for development)
- kcov (for test coverage)

## Environment Variables

Core:

- PURR_HOME: Installation directory
- PURR_LIB: Library directory
- PURR_CONFIG_HOME: User config directory
- PURR_DATA_HOME: User data directory
- PURR_CACHE_HOME: User cache directory
- PURR_SYSTEM_CONFIG: System config directory

Runtime:

- SSH_AUTH_SOCK: SSH agent socket
- GPG_TTY: GPG terminal
- SHELL: User's shell
