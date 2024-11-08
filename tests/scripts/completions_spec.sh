#!/usr/bin/env bash
Describe 'completions.sh'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_completions() {
    mkdir -p tests/dev/dist/completion docs

    # Create both .md and generated man page
    cat > docs/purr.1.md <<EOF
# NAME
purr - Key management utility

# COMMANDS
status
    Show current state
keys
    Manage SSH and GPG keys
EOF

    cat > docs/purr.1 <<EOF
.TH PURR 1
.SH NAME
purr \- Key management utility
.SH COMMANDS
.TP
.B status
Show current state
.TP
.B keys
Manage SSH and GPG keys
EOF

    # Mock go-md2man
    cat > /tmp/go-md2man <<'EOF'
#!/bin/sh
cat "$2"
EOF
    chmod +x /tmp/go-md2man
    export PATH="/tmp:$PATH"
  }

  BeforeEach 'setup_completions'

  It 'generates shell completions'
    When run script ./scripts/completions.sh docs/purr.1 tests/dev/dist/completion
    The status should be success
    The path 'tests/dev/dist/completion/completion.zsh' should be file
    The path 'tests/dev/dist/completion/completion.bash' should be file
    The output should include 'Generated shell completions in tests/dev/dist/completion'
  End
End
