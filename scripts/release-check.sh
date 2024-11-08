#!/bin/bash

set -eu

# Source metadata
. ./metadata.sh

check_version() {
    if [ ! -f VERSION ]; then
        error "VERSION file missing"
        return 1
    fi
    success "Version file exists"
}

check_docs() {
    if [ ! -f docs/purr.1.md ]; then
        error "Man page source missing"
        return 1
    fi
    success "Documentation exists"
}

check_tests() {
    make test
    success "Tests passed"
}

check_dist() {
    make dist
    if [ ! -f "dist/purr-${VERSION}.tar.gz" ]; then
        error "Distribution archive missing"
        return 1
    fi
    success "Distribution archive created"
}

check_formula() {
    ./scripts/generate-formula.sh
    if [ ! -f Formula/purr.rb ]; then
        error "Homebrew formula missing"
        return 1
    fi
    success "Homebrew formula generated"
}

main() {
    echo "Running release checks..."
    check_version
    check_docs
    check_tests
    check_dist
    check_formula
    echo "✨ Release checks passed!"
}

main "$@"
