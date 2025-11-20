# Development Guide

This guide covers setting up a development environment for purr and contributing to the project.

## Development Setup

### Prerequisites

- macOS
- ZSH shell
- Git
- 1Password CLI (for testing)
- ShellCheck: `brew install shellcheck`
- bats: `brew install bats-core`
- Prettier: `npm install -g prettier@3.2.5`
- Node.js 20+ (for Prettier)

### Clone and Setup

```bash
git clone https://github.com/m3au/purr.git
cd purr
```

### Testing

Run tests:
```bash
bats tests/*.bats
```

### Linting

Check shell script:
```bash
shellcheck purr.zsh
```

### Formatting

Format markdown and JSON:
```bash
prettier --write '*.{json,md}' '**/*.{json,md}'
```

## Project Structure

```
purr/
├── .github/
│   ├── workflows/
│   │   └── ci.yml              # GitHub Actions CI workflow
│   └── ISSUE_TEMPLATE/         # Issue templates
├── docs/                        # Additional documentation
│   ├── setup.md
│   ├── configuration.md
│   ├── troubleshooting.md
│   └── development.md
├── tests/                       # Test suite
│   ├── test_helper.bats        # Test helper functions
│   └── purr.bats               # Main test file
├── purr.zsh                     # Main script
├── README.md                    # Main documentation
├── CONTRIBUTING.md              # Contribution guidelines
├── SECURITY.md                  # Security policy
├── CHANGELOG.md                 # Version history
└── package.json                 # Project metadata
```

## Code Style

### Shell Script Style

- Use 2-space indentation
- Quote all variables: `"$variable"` not `$variable`
- Use local variables in functions
- Add function documentation headers
- Follow ShellCheck recommendations

### Function Documentation

Add documentation before each function:

```zsh
# Function name: brief description
# Arguments:
#   $1: description
# Returns: description
# Environment: description if relevant
# Example: usage example
function_name() {
  # implementation
}
```

## Development Workflow

1. **Create a branch:**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes:**
   - Follow code style guidelines
   - Add tests for new features
   - Update documentation

3. **Test your changes:**
   ```bash
   shellcheck purr.zsh
   bats tests/*.bats
   ```

4. **Commit:**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push and create PR:**
   ```bash
   git push origin feature/my-feature
   ```

## Testing Guidelines

### Writing Tests

- Add tests for new functions
- Test both success and error paths
- Mock external commands where appropriate
- Keep tests focused and readable

### Test Structure

```bash
@test "description of what is being tested" {
  # Arrange
  setup_test_environment
  
  # Act
  result=$(function_to_test "input")
  
  # Assert
  [ "$result" = "expected_output" ]
}
```

## Continuous Integration

CI runs automatically on push and pull requests:

- **Lint**: ShellCheck on `purr.zsh`
- **Test**: bats test suite
- **Format**: Prettier on markdown/JSON files

All checks must pass before merging.

## Release Process

1. Update `CHANGELOG.md` with new features/fixes
2. Update version in relevant files
3. Create git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release with release notes

## Debugging

### Enable Verbose Mode

Most functions support verbose output:

```zsh
purr -v
```

### Test Individual Functions

Source the script and call functions directly:

```zsh
source purr.zsh
load_gpg_key true  # verbose mode
```

### Check Environment

```zsh
echo "Vault: $PURR_VAULT_NAME"
echo "GPG Item: $PURR_GPG_ITEM"
echo "SSH Socket: $PURR_SSH_AUTH_SOCK"
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed contribution guidelines.

## Questions?

- Open an issue for bugs or feature requests
- Check existing issues and discussions
- Review documentation in `docs/` directory

