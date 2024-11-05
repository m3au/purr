#!/usr/bin/env bash

BATS_SUPPORT_PATH="../node_modules/bats-support/load.bash"
BATS_ASSERT_PATH="../node_modules/bats-assert/load.bash"

if [ -f "$BATS_SUPPORT_PATH" ]; then
  load '../node_modules/bats-support/load'
else
  echo "Warning: bats-support not found. Please run 'npm install'" >&2
fi

if [ -f "$BATS_ASSERT_PATH" ]; then
  load '../node_modules/bats-assert/load'
else
  echo "Warning: bats-assert not found. Please run 'npm install'" >&2
fi
