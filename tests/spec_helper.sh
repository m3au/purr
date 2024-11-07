#!/usr/bin/env bash

# Get the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DIR/.." && pwd)"

# Test framework functions
describe() {
    echo "Testing: $1"
}

it() {
    echo "  - $1"
}

assert() {
    if [ "$1" = "$2" ]; then
        echo "    ✓ Pass"
        return 0
    else
        echo "    ✗ Fail: Expected '$2', got '$1'"
        return 1
    fi
}

end() {
    :  # No-op
}
