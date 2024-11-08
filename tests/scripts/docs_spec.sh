#!/usr/bin/env bash
Describe 'Documentation generation'
  Include tests/spec_helper.sh
  BeforeEach 'setup_test_env'
  AfterEach 'cleanup_test_env'

  setup_docs() {
    # Mock generate-docs.sh
    cat > /tmp/generate-docs.sh <<'EOF'
#!/bin/sh
mkdir -p docs
case "$1" in
  background)
    echo "# Project Context" > docs/background.md
    ;;
  context)
    echo "# Project Status" > docs/context.md
    ;;
  *)
    echo "# Project Context" > docs/background.md
    echo "# Project Status" > docs/context.md
    ;;
esac
EOF
    chmod +x /tmp/generate-docs.sh
    export PATH="/tmp:$PATH"
  }

  BeforeEach 'setup_docs'

  It 'generates background documentation'
    When run script ./scripts/generate-docs.sh background
    The status should be success
    The path 'docs/background.md' should be file
    The contents of file 'docs/background.md' should include 'Project Context'
  End

  It 'generates context documentation'
    When run script ./scripts/generate-docs.sh context
    The status should be success
    The path 'docs/context.md' should be file
    The contents of file 'docs/context.md' should include 'Project Status'
  End
End
