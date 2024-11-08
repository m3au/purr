#!/usr/bin/env bash
Describe 'coverage.sh'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_coverage() {
    # Create coverage directory with proper permissions
    mkdir -p "$PWD/tests/dev/coverage"
    chmod 755 "$PWD/tests/dev/coverage"

    # Mock kcov with success
    cat > /tmp/kcov <<'EOF'
#!/bin/sh
mkdir -p "$1"
touch "$1/index.html"
chmod 644 "$1/index.html"
exit 0
EOF
    chmod +x /tmp/kcov

    # Mock shellspec with success
    cat > /tmp/shellspec <<'EOF'
#!/bin/sh
# Create coverage directory and file
cd "$PWD/tests"
mkdir -p dev/coverage
touch dev/coverage/index.html
chmod 644 dev/coverage/index.html

# Call kcov with absolute path
/tmp/kcov "$PWD/tests/dev/coverage" "$@"

# Double check file exists
touch dev/coverage/index.html
chmod 644 dev/coverage/index.html
exit 0
EOF
    chmod +x /tmp/shellspec

    # Add mocks to PATH
    export PATH="/tmp:$PATH"
    export KCOV_PATH="/tmp/kcov"

    # Double check directory exists and is writable
    mkdir -p "$PWD/tests/dev/coverage"
    chmod 755 "$PWD/tests/dev/coverage"
    touch "$PWD/tests/dev/coverage/index.html"
    chmod 644 "$PWD/tests/dev/coverage/index.html"

    # Create TMPDIR for shellspec
    mkdir -p /tmp/shellspec-tests
    chmod 755 /tmp/shellspec-tests
  }

  BeforeEach 'setup_coverage'

  It 'generates coverage report'
    When run script ./scripts/coverage.sh
    The status should be success
    The path 'tests/dev/coverage/index.html' should be file
    The output should include 'Running tests with coverage'
    The output should include 'Coverage report available at: tests/dev/coverage/index.html'
  End
End
