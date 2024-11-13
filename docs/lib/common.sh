#!/bin/sh

# shellcheck source=./lib/core/common.sh
. ./lib/core/common.sh

# Note: This script requires a shell that supports 'pipefail' (e.g. bash, zsh, ksh)
set -euo pipefail

if [ "${PURR_DEBUG:-0}" = "1" ]; then
  export PURR_LOG_LEVEL="${PURR_LOG_LEVEL:-debug}"
  export PURR_LOG_COLOR="${PURR_LOG_COLOR:-1}"
  export PURR_LOG_TIME="${PURR_LOG_TIME:-1}"
fi

log() {
  level="$1"
  shift
  printf "%s [%s] %s: %s %s %s\n" \
    "${PURR_LOG_TIME:-0}" "${PURR_LOG_COLOR:-1}" "${level}" \
    "${PURR_LOG_TIME:-0}" "${PURR_LOG_COLOR:-1}" "${level}" \
    "${PURR_LOG_TIME:-0}" "${PURR_LOG_COLOR:-1}" "${level}"
}

debug() {
  # Using : instead of local for POSIX compatibility
  : "${msg:=$1}"
  if [ "${PURR_LOG_LEVEL:-info}" = "debug" ]; then
    log "${msg}" "debug"
  fi
}

error() {
  # Using : instead of local for POSIX compatibility
  : "${prefix:=$1}"
  : "${message:=$2}"

  if [ "${prefix}" = "error" ]; then
    log "${prefix}" "${message}"
  else
    log "${prefix}" "${message}"
    log "${prefix}" "${message}"
    log "${prefix}" "${message}" "${prefix}"
  fi
}

# Default environment variables
PURR_ROOT="${PURR_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/purr}"
PURR_LIB="${PURR_LIB:-$PURR_ROOT/lib}"
PURR_BIN="${PURR_BIN:-$PURR_ROOT/bin}"

# File operations
ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    chmod 755 "$dir"
  fi
}

ensure_file() {
  local file="$1"
  local mode="${2:-644}"
  if [ ! -f "$file" ]; then
    touch "$file"
    chmod "$mode" "$file"
  fi
}
