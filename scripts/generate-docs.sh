#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail

# Get the type of documentation to generate
DOC_TYPE="${1:-}"

# Validate input
if [[ -z "$DOC_TYPE" ]]; then
    echo "Usage: $0 [background|context]" >&2
    exit 1
fi

echo "Generating ${DOC_TYPE}.md..."

case "$DOC_TYPE" in
    background)
        cat << EOF
# Project Context

Generated: $(date)

## About This Document

$(cat scripts/background.sh)

## Project Rules
$(grep -h "^[0-9]" docs/background.md 2>/dev/null || echo "No rules defined yet")

## Project Structure
\`\`\`
$(tree -L 3)
\`\`\`

## Module Dependencies
$(grep -h "^graph" docs/background.md 2>/dev/null || echo "Dependencies not defined yet")

## Core Modules
$(find src/lib/core -type f -name "*.sh" | sort | sed 's/.*\/\(.*\)\.sh/- **\1**:/')

## Command Modules
$(find src/lib/commands -type f -name "*.sh" | sort | sed 's/.*\/\(.*\)\.sh/- **\1**:/')

## Test Coverage
$(scripts/coverage.sh 2>/dev/null || echo "Coverage report not available")

## Latest Changes
\`\`\`
$(git log -5 --oneline)
\`\`\`
EOF
        ;;
    context)
        cat << EOF
# Project Status
Generated: $(date)

$(cat scripts/context.sh)

## Notes
- Remember to maintain test coverage while developing
- Keep security as top priority
- Document all shell compatibility issues
- Track performance impacts
- Keep installation footprint minimal

## Environment Variables
$(grep -h "^PURR_" src/lib/core/env.sh 2>/dev/null || echo "No environment variables defined yet")

## Dependencies
Required:
$(grep -h "^depends" src/lib/core/env.sh 2>/dev/null || echo "- Dependencies not defined yet")

Optional:
$(grep -h "^optional" src/lib/core/env.sh 2>/dev/null || echo "- Optional dependencies not defined yet")
EOF
        ;;
    *)
        echo "Invalid documentation type: $DOC_TYPE" >&2
        exit 1
        ;;
esac

echo "✓ Generated ${DOC_TYPE}.md"
