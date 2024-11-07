#!/usr/bin/env bash

# Source the test helper
source "$(dirname "$0")/spec_helper.sh"

describe "Basic test framework"
  it "should perform basic assertions"
    assert "true" "true"
  end

  it "should handle basic shell commands"
    result=$(echo "hello")
    assert "$result" "hello"
  end

  it "should have access to project root"
    [ -d "$PROJECT_ROOT" ]
    assert "$?" "0"
  end
end
