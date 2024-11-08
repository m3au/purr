#!/bin/sh

# This script generates a comprehensive project context document (background.md)
# specifically designed for AI assistants like Claude. It provides:
# - Project rules and conventions
# - File structure and organization
# - Module dependencies and relationships
# - Command and data flows
# - Test coverage metrics
# - Recent changes
# The output is formatted in markdown with mermaid diagrams for better visualization.

OUTPUT_FILE="docs/background.md"

{
    echo "# Project Context"
    echo
    echo "Generated: $(date)"
    echo

    echo "## About This Document"
    cat << 'EOF'
This document provides comprehensive project context for AI assistants like Claude. It includes:
- Project rules and conventions
- File structure and organization
- Module dependencies and relationships
- Command and data flows
- Test coverage metrics
- Recent changes
The output is formatted in markdown with mermaid diagrams for better visualization.
EOF
    echo

    echo "## Project Rules"
    echo "1. No whitespace-only changes"
    echo "2. No hallucinated code/comments"
    echo "3. Follow XDG Base Directory Specification"
    echo "4. Maintain test coverage"
    echo "5. Use shellcheck for linting"
    echo "6. Keep modules focused and small"
    echo "7. Use common functions for output"
    echo "8. Proper error handling and exit codes"
    echo "9. Secure handling of sensitive data"
    echo "10. Consistent style and formatting"
    echo "11. Don't add comments to the code at all"

    echo "## Project Structure"
    echo '```'
    tree -I 'node_modules|coverage|.git'
    echo '```'
    echo

    echo "## Module Dependencies"
    echo '```mermaid'
    echo 'graph TD'
    echo '  purr --> common'
    echo '  purr --> color'
    echo '  purr --> env'
    echo '  purr --> auth'
    echo '  purr --> git'
    echo '  purr --> ssh'
    echo '  purr --> gpg'
    echo '  purr --> config'
    echo '  auth --> common'
    echo '  auth --> color'
    echo '  git --> common'
    echo '  git --> color'
    echo '  ssh --> common'
    echo '  gpg --> common'
    echo '  config --> common'
    echo '```'
    echo

    echo "## Core Modules"
    for file in src/lib/core/*.sh; do
        name=$(basename "$file")
        desc=$(head -n 3 "$file" | grep -v '^#!' | grep '^#' | sed 's/^#//' || echo "No description")
        echo "- **$name**:$desc"
    done
    echo

    echo "## Command Modules"
    find src/lib/commands -name "*.sh" | while read -r file; do
        name=$(basename "$file")
        dir=$(dirname "$file" | sed 's|src/lib/commands/||')
        desc=$(head -n 3 "$file" | grep -v '^#!' | grep '^#' | sed 's/^#//' || echo "No description")
        echo "- **$dir/$name**:$desc"
    done
    echo

    echo "## Test Coverage"
    total_files=$(find src/lib -name "*.sh" | wc -l)
    test_files=$(find tests -name "*_spec.sh" | wc -l)
    echo "- Source Files: $total_files"
    echo "- Test Files: $test_files"
    echo "- Coverage: $((test_files * 100 / total_files))%"
    echo

    echo "## Latest Changes"
    echo '```'
    git log -5 --pretty=format:"%h - %s (%cr)" --abbrev-commit
    echo '```'

    echo "## Command Flow"
    echo '```mermaid'
    echo 'graph LR'
    echo '  install --> backup'
    echo '  update --> backup'
    echo '  update --> install'
    echo '  reset --> backup'
    echo '  doctor --> verify'
    echo '  status --> check_keys'
    echo '  keys --> ssh'
    echo '  keys --> gpg'
    echo '  gpg --> git'
    echo '```'
    echo

    echo "## Data Flow"
    echo '```mermaid'
    echo 'graph TD'
    echo '  1Password --> SSH_Keys'
    echo '  1Password --> GPG_Keys'
    echo '  SSH_Keys --> ssh-agent'
    echo '  GPG_Keys --> gpg-agent'
    echo '  GPG_Keys --> git_signing'
    echo '  config --> XDG_CONFIG_HOME'
    echo '  backups --> XDG_DATA_HOME'
    echo '  cache --> XDG_CACHE_HOME'
    echo '```'
    echo

    echo "## File Purposes"
    echo "- src/bin/purr: Main executable entry point"
    echo "- src/lib/core/: Core functionality modules"
    echo "- src/lib/commands/: Command implementation modules"
    echo "- src/completion/: Shell completion scripts"
    echo "- tests/: Test files for each module"
    echo "- docs/: Documentation and man pages"
    echo

} > "$OUTPUT_FILE"
