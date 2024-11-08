#!/usr/bin/env shellspec

Describe 'help.sh'
  Include scripts/help.sh

  Describe 'help output'
    It 'shows usage'
      When run script scripts/help.sh
      The output should include "Usage: make [target]"
    End

    It 'shows targets section'
      When run script scripts/help.sh
      The output should include "Targets:"
    End

    It 'shows target descriptions'
      When run script scripts/help.sh
      The output should include "background"
      The output should include "clean"
      The output should include "completions"
    End

    It 'formats target descriptions'
      When run script scripts/help.sh
      The line 1 should equal "Usage: make [target]"
      The line 3 should equal "Targets:"
      The line 4 should start with "  "
      The line 5 should start with "  "
      The line 6 should start with "  "
    End
  End
End
