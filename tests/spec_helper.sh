#!/usr/bin/env bash
# shellcheck shell=bash

# ShellSpec framework configuration
spec_helper_precheck() {
  : minimum_version "0.28.1"
}

spec_helper_loaded() {
  :
}

spec_helper_configure() {
  : import 'support/custom_matcher'
}

# Project-specific configuration
export PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Add project lib to PATH
PATH="${PROJECT_ROOT}/lib:${PATH}"

# Set PURR_HOME to a subdirectory of TMPDIR
export PURR_HOME="${TMPDIR}/purr"

# Debug info
echo "=== Test Environment ==="
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "TMPDIR: $TMPDIR"
echo "PURR_HOME: $PURR_HOME"
echo "PATH: $PATH"
echo "Available test files:"
find "${PROJECT_ROOT}/tests" -name "*.spec" -type f

# Load common modules
Include() {
  local module="$1"
  echo "Including module: $module"
  # shellcheck disable=SC1090
  . "${PROJECT_ROOT}/${module}"
}
