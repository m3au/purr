#!/bin/bash

set -eu

COVERAGE_DIR="tests/dev/coverage"
TMPDIR="${TMPDIR:-/tmp/shellspec-tests}"

mkdir -p "$TMPDIR" "$COVERAGE_DIR"

echo "Running tests with coverage..."
cd tests && \
SHELLSPEC_LOAD_PATH=. shellspec --shell /bin/bash \
    --kcov \
    --kcov-options "--include-pattern=.sh,install,Makefile \
                    --exclude-pattern=_spec.sh \
                    --exclude-path=tests \
                    --exclude-path=coverage \
                    --clean" \
    --kcov-path "${KCOV_PATH:-/opt/homebrew/bin/kcov}" \
    *_spec.sh

echo "Coverage report available at: $COVERAGE_DIR/index.html"
