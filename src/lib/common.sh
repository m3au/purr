#!/bin/sh

# Use strict error handling for POSIX shell
set -eu

# Output functions
handle_error() {
  error_msg="$1"
  error_code="${2:-1}"

  printf "❌ %s\n" "${error_msg}" >&2
  return "${error_code}"
}

success() {
  printf "✓ %s\n" "$1"
}

error() {
  printf "❌ %s\n" "$1"
}

info() {
  printf "➜ %s\n" "$1"
}

# Debug and logging
if [ "${PURR_DEBUG:-0}" = "1" ]; then
  export PURR_LOG_LEVEL="${PURR_LOG_LEVEL:-debug}"
  export PURR_LOG_COLOR="${PURR_LOG_COLOR:-1}"
  export PURR_LOG_TIME="${PURR_LOG_TIME:-1}"
fi

log() {
  level="$1"
  shift
  msg="$*"

  if [ "${PURR_LOG_TIME:-0}" = "1" ]; then
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  else
    timestamp=""
  fi

  if [ "${PURR_LOG_COLOR:-1}" = "1" ]; then
    case "${level}" in
    debug) color="\033[36m" ;; # cyan
    info) color="\033[32m" ;;  # green
    warn) color="\033[33m" ;;  # yellow
    error) color="\033[31m" ;; # red
    *) color="\033[0m" ;;      # default
    esac
    reset="\033[0m"
  else
    color=""
    reset=""
  fi

  printf '%s[%s%s%s] %s\n' \
    "${timestamp:+${timestamp} }" \
    "${color}" "${level}" "${reset}" \
    "${msg}"
}

debug() {
  : "${msg:=$1}"
  if [ "${PURR_LOG_LEVEL:-info}" = "debug" ]; then
    log "${msg}" "debug"
  fi
}

# Default environment variables
PURR_ROOT="${PURR_ROOT:-${XDG_DATA_HOME:-${HOME}/.local/share}/purr}"
PURR_LIB="${PURR_LIB:-${PURR_ROOT}/lib}"
PURR_BIN="${PURR_BIN:-${PURR_ROOT}/bin}"

# File operations
ensure_dir() {
  dir="$1"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
    chmod 755 "${dir}"
  fi
}

ensure_file() {
  file="$1"
  mode="${2:-644}"
  if [ ! -f "${file}" ]; then
    touch "${file}"
    chmod "${mode}" "${file}"
  fi
}
