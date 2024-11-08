#!/usr/bin/env shellspec

Describe 'Documentation generation'
  It 'generates background documentation'
    When run script ./scripts/generate-docs.sh background
    The status should be success
    The output should include "Generating background.md..."
    The output should include "✓ Generated background.md"
  End

  It 'generates context documentation'
    When run script ./scripts/generate-docs.sh context
    The status should be success
    The output should include "Generating context.md..."
    The output should include "✓ Generated context.md"
  End
End
