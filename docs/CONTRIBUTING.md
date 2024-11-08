# Development Guide

## Project Structure

```text
.
├── docs/                   # Documentation
│   ├── SECURITY.md        # Security policy
│   ├── background.md      # Project background (generated)
│   ├── backlog.md        # Project backlog
│   ├── context.md        # Project context (generated)
│   ├── goal.md          # Project goals
│   ├── guides/          # User and developer guides
│   └── purr.1.md       # Man page source
├── scripts/
│   ├── ai/             # AI documentation generators
│   │   ├── background.ai
│   │   └── context.ai
│   └── dev.sh         # Development task runner
├── src/
│   ├── bin/           # Main executable
│   ├── completion/    # Shell completions
│   └── lib/           # Library files
│       ├── commands/  # Command implementations
│       │   ├── config/
│       │   ├── keys/
│       │   ├── status/
│       │   └── system/
│       └── core/      # Core functionality
└── tests/             # Test files
```

## Development Setup

### Requirements

These will be automatically installed by `make setup`:

- shellcheck (for linting)
- shfmt (for formatting)
- kcov (for test coverage)
- md2man-roff (for man pages)
- shellspec (for testing)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/m3au/purr.git
   cd purr
   ```

2. Set up development environment:
   ```bash
   make setup
   ```
   This will:
   - Install all required development tools
   - Create development directories
   - Set up environment variables
   - Configure shell integration

### Development Commands

```bash
# Set up development environment
make setup

# Run basic tests
make test

# Run all tests
make test-all

# Generate test coverage
make coverage

# Lint shell scripts
make lint

# Format code
make format

# Generate man pages
make man

# Clean development files
make clean

# Generate documentation
make context
make background

# Show all available commands
./scripts/dev.sh help
```

## Code Style

### Shell Scripts

- Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use shellcheck for linting
- Keep functions focused and documented
- Use shfmt for consistent formatting

### Configuration Files

- .editorconfig: Editor configuration
- .shellcheckrc: Shell script linting rules
- .markdownlint.json: Markdown linting rules
- .cspell.json: Spell checking configuration

## Testing

### Test Structure

Tests match the source structure:

```text
tests/
├── auth_spec.sh       # Tests for src/lib/core/auth.sh
├── backup_spec.sh     # Tests for src/lib/commands/config/backup.sh
├── color_spec.sh      # Tests for src/lib/core/color.sh
├── ...
└── spec_helper.sh  # Common test helpers
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

## Documentation

- Keep documentation up to date
- Use clear, concise language
- Include examples where helpful
- Follow markdownlint rules

## Pull Requests

1. Create a branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes:
   - Update documentation
   - Follow code style guidelines
   - Add/update tests
   - Run tests locally

3. Create a pull request:
   - Clear description
   - Related issues
   - Testing steps

## Security

- Never commit sensitive keys
- Report security issues privately
- Follow [Security Policy](docs/SECURITY.md)

## Questions?

Open an issue for any questions about contributing.
