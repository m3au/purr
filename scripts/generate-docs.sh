#!/bin/bash

set -eu

# Source project metadata
. ./metadata.sh

generate_background() {
    cat > docs/background.md <<EOF
# Project Context
Generated: $(date)
## About This Document
This document provides:
- Project rules and conventions
- File structure and organization
- Module dependencies and relationships
- Command and data flows
EOF
}

generate_context() {
    cat > docs/context.md <<EOF
# Project Status
Generated: $(date)
## About This Document
This document provides:
- A list of TODOs, FIXMEs, and XXXs from the source files
EOF
}

main() {
    local doc_type="${1:-all}"

    case "$doc_type" in
        background)
            generate_background
            ;;
        context)
            generate_context
            ;;
        all)
            generate_background
            generate_context
            ;;
        *)
            echo "Unknown documentation type: $doc_type"
            exit 1
            ;;
    esac
}

main "$@"
