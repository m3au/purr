# Contributing Guide

## Project Structure

The project follows this directory structure:

```text
~/.purr/
├── backup/         # Configuration backups
├── lib/
│   ├── modules/
│   │   ├── core/      # Core functionality
│   │   └── commands/  # Command implementations
│   └── purr          # Main script
├── scripts/          # Shell integration
└── man/             # Man pages (if md2man installed)
```

All directories are created with 700 permissions for security.

## Architecture

### Overview

Purr is designed as a modular shell script application with a focus on simplicity and POSIX compliance. The project follows a clear separation of concerns with distinct modules for different functionalities.

### Directory Structure

```text
purr/
├── bin/                    # Main executable
├── docs/                   # Documentation
├── lib/                    # Core library files
│   ├── purr               # Main library entry point
│   └── modules/           # Modular functionality
│       ├── core/          # Core functionality
│       │   ├── config.sh  # Configuration management
│       │   ├── git.sh     # Git integration
│       │   ├── gpg.sh     # GPG key management
│       │   ├── init.sh    # Core initialization
│       │   ├── ssh.sh     # SSH key management
│       │   └── utils.sh   # Utility functions
│       └── commands/      # Command implementations
│           ├── config/    # Configuration commands
│           ├── keys/      # Key management commands
│           ├── status/    # Status checking commands
│           └── system/    # System management commands
└── scripts/               # Helper scripts
```

### Core Concepts

1. **Modularity**: Each functionality is isolated in its own module
2. **POSIX Compliance**: All scripts follow POSIX shell standards
3. **Error Handling**: Consistent error handling across modules
4. **Configuration**: Centralized configuration management
5. **Security**: Secure handling of sensitive data

### Command Structure

Commands follow a consistent pattern:

1. Input validation
2. Environment checks
3. Command execution
4. Status reporting

### Environment Variables

Core environment variables:

- `PURR_HOME`: Installation directory
- `PURR_LIB`: Library directory
- `PURR_ROOT`: Project root directory

### Error Handling

All modules use the `handle_error` function for consistent error reporting.

### Testing

Tests are written using shellspec and follow the same modular structure as the main code.

## Development Guidelines

- Use conventional commits
- Sign your commits (required)
- Keep commits focused
- Clear messages
- Run `bun run precommit` before committing

Example:

```bash
feat: add support for custom key naming
fix: resolve SSH agent connection issue
docs: update setup instructions
```

## IDE Setup

We recommend using [Cursor](https://cursor.sh) as the primary IDE. The project includes a `app.code-workspace`
file that configures:

- Shell script formatting and linting
- Markdown formatting
- Git commit signing
- Recommended extensions
- File exclusions

To get started:

1. Open the project in Cursor
2. File → Open Workspace from File...
3. Select `app.code-workspace`

### Package Management

We use [Bun](https://bun.sh) for development dependencies and scripts - no runtime dependencies are required.

Available scripts:

```bash
# Run shellcheck on all shell scripts
bun run test

# Watch mode - run shellcheck on file changes
bun run test:watch

# Lint shell scripts
bun run lint

# Auto-fix shell script formatting
bun run lint:fix

# Format JSON and markdown files
bun run format

# Pre-commit checks
bun run precommit
```

## Getting Started

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/YOUR_USERNAME/purr.git
   ```

3. Create a new branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

## Code Style

### Shell Scripts

- Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use shellcheck for linting (`bun run lint`)
- Keep functions focused and documented
- Maximum line length: 80 characters
- Use `shfmt` for consistent formatting (`bun run lint:fix`)

### Documentation

- Keep documentation up to date
- Use clear, concise language
- Include examples where helpful
- Format with Prettier (`bun run format`)

## Testing

### Setting Up Test Environment

1. Install ShellSpec:

    ```bash
    curl -fsSL https://git.io/shellspec | sh
    ```

2. Initialize ShellSpec in the project:

    ```bash
    shellspec --init
    ```

This creates:

- `.shellspec` configuration file
- Basic test structure

### Running Tests

Available test commands:

```bash
# Run all tests
bun test

# Generate coverage report
bun coverage
```

### Coverage Requirements

To generate coverage reports, you'll need kcov:

For Ubuntu/Debian:

```bash
sudo apt-get install kcov
```

For macOS:

```bash
brew install kcov
```

### Test Structure

Tests follow the project's modular structure:

```text
tests/
├── core.spec     # Core functionality tests
├── gpg.spec      # GPG-related tests
├── ssh.spec      # SSH-related tests
├── utils.spec    # Utility function tests
└── spec_helper.sh # Common test helpers
```

### Writing Tests

Tests should:

- Follow ShellSpec syntax
- Include clear descriptions
- Test both success and failure cases
- Mock external dependencies when needed

Example test:

```bash
Describe 'utils'
  Include lib/modules/core/utils.sh

  It 'validates input correctly'
    When call validate_input "test"
    The status should be success
    The output should include "valid"
  End
End
```

For more details on writing tests, see the [ShellSpec documentation](https://github.com/shellspec/shellspec#documentation).

## Pull Requests

1. Update documentation
2. Follow code style guidelines
3. Test thoroughly
4. Include in PR:
   - Clear description
   - Related issues
   - Testing steps

## Security

- Never commit sensitive keys
- Report security issues privately
- Follow [Security Policy](../../SECURITY.md)

## Questions?

Open an issue for any questions about contributing.
