#!/usr/bin/env bash
Describe 'publish.sh'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_publish() {
    export SKIP_GIT=1
    export SKIP_TEST=1
    mkdir -p docs dist/{man,completion}
    touch docs/purr.1.md
    touch dist/man/purr.1
    touch dist/completion/completion.{zsh,bash}

    # Mock go-md2man
    cat > /tmp/go-md2man <<'EOF'
#!/bin/sh
touch dist/man/purr.1
EOF
    chmod +x /tmp/go-md2man

    # Mock generate-formula.sh
    cat > /tmp/generate-formula.sh <<'EOF'
#!/bin/sh
mkdir -p Formula
touch Formula/purr.rb
EOF
    chmod +x /tmp/generate-formula.sh

    # Add mocks to PATH
    export PATH="/tmp:$PATH"

    # Create test distribution
    mkdir -p dist
    touch dist/purr-1.0.0.tar.gz
  }

  BeforeEach 'setup_publish'

  It 'publishes new version'
    When run script ./scripts/publish.sh 1.0.0
    The status should be success
    The output should include 'Published v1.0.0'
  End
End
