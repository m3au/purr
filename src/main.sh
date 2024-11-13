#!/bin/sh

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source common functions first
. "${SCRIPT_DIR}/lib/common.sh"

# Then source command modules
. "${SCRIPT_DIR}/lib/commands/system/version.sh"
