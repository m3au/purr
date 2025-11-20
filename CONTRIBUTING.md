# Contributing to purr

Thank you for your interest in contributing to purr! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:

- A clear title and description
- Steps to reproduce the bug
- Expected vs actual behavior
- Your environment (OS version, ZSH version, 1Password CLI version)
- Relevant error messages or logs (with sensitive data removed)

### Suggesting Features

Feature suggestions are welcome! Please open an issue with:

- A clear description of the feature
- Use cases and examples
- Potential implementation ideas (if any)

### Pull Requests

1. **Fork the repository** and create a feature branch
2. **Follow the code style**:
   - Use ShellCheck for linting
   - Follow existing code formatting
   - Add comments for complex logic
3. **Test your changes**:
   - Test on macOS
   - Test with actual 1Password integration (if possible)
   - Ensure no sensitive data is logged
4. **Update documentation**:
   - Update README.md if adding new features
   - Update CHANGELOG.md
   - Add function documentation for new functions
5. **Submit your PR** with a clear description of changes

## Development Setup

### Prerequisites

- macOS
- ZSH shell
- 1Password CLI (`op`) installed and configured
- ShellCheck for linting: `brew install shellcheck`
- Bats for testing: `brew install bats`

### Running Tests

Tests are written using [bats](https://github.com/bats-core/bats-core):

```bash
# Install bats if not already installed
brew install bats-core

# Run all tests
bun test

# Or run directly with bats
bats tests/*.bats

# Run specific test file
bats tests/purr.bats
```

### Writing Tests

- Add tests for new functions in `tests/purr.bats`
- Use the test helper functions from `tests/test_helper.bats` for setup/teardown
- Mock external commands (like `op`, `gpg`) where appropriate
- Test both success and error paths
- Keep tests focused and readable

### Linting

```bash
bun run lint
```

### Formatting

```bash
bun run format
```

## Code Style Guidelines

### Shell Script Style

- Use 2-space indentation
- Quote all variables: `"$variable"` not `$variable`
- Use local variables in functions
- Add comments for complex logic
- Keep functions focused and small

### Function Documentation

Add a comment block before each function:

```zsh
# Function name: brief description
# Arguments:
#   $1: description
# Returns: description
# Example: usage example
function_name() {
  # implementation
}
```

### Error Handling

- Return 0 on success, non-zero on failure
- Provide clear error messages
- Clean up resources on error
- Never expose sensitive data in error messages

## Commit Messages

Follow conventional commits format:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `refactor:` for code refactoring
- `test:` for test additions/changes
- `chore:` for maintenance tasks

Example:

```
feat: add support for configurable SSH agent socket path

Allow users to override the default SSH agent socket path via
PURR_SSH_AUTH_SOCK environment variable.
```

## Review Process

1. All PRs require review before merging
2. CI checks must pass (linting, tests)
3. Code review feedback should be addressed
4. Maintainers will merge approved PRs

## Questions?

Feel free to open an issue for questions or reach out to the maintainers.

Thank you for contributing to purr! 🐱
