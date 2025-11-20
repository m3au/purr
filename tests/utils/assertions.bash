#!/usr/bin/env bash
# Test assertion utilities for purr tests

# Assert that a command succeeds
assert_success() {
  if [ "$status" -eq 0 ]; then
    return 0
  else
    echo "Expected success but got exit code $status" >&2
    echo "Output: $output" >&2
    return 1
  fi
}

# Assert that a command fails
assert_failure() {
  if [ "$status" -ne 0 ]; then
    return 0
  else
    echo "Expected failure but got exit code 0" >&2
    echo "Output: $output" >&2
    return 1
  fi
}

# Assert output contains a string
assert_output_contains() {
  local expected=$1
  if echo "$output" | grep -q "$expected"; then
    return 0
  else
    echo "Expected output to contain '$expected' but it didn't" >&2
    echo "Output: $output" >&2
    return 1
  fi
}

# Assert that a file exists
assert_file_exists() {
  local file=$1
  if [ -f "$file" ]; then
    return 0
  else
    echo "Expected file '$file' to exist but it doesn't" >&2
    return 1
  fi
}
