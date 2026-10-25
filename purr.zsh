#!/usr/bin/env zsh
# purr - one-time SSH, GPG, and Git signing setup with 1Password
# shellcheck disable=SC1090

# Refuse direct execution in zsh and bash. Sourcing (including the lazy-load
# wrapper that sources this file and then calls purr) must keep going.
purr_invoked_as_script() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    case :${ZSH_EVAL_CONTEXT:-}: in
      *:file:*) return 1 ;;
      *) return 0 ;;
    esac
  fi
  if [ -n "${BASH_VERSION:-}" ]; then
    if [ "${BASH_SOURCE[0]}" = "$0" ]; then
      return 0
    fi
    return 1
  fi
  return 1
}

if purr_invoked_as_script; then
  printf '%s\n' "This script should be sourced, not executed directly." >&2
  exit 1
fi

# Configuration: 1Password vault and item names.
# Override these with environment variables or ~/.purrrc.
PURR_VAULT_NAME="${PURR_VAULT_NAME:-purr}"
PURR_GPG_ITEM="${PURR_GPG_ITEM:-gpg}"
PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"

# SSH agent socket and GPG cache TTL. The socket is written into ~/.ssh/config
# as IdentityAgent; exporting SSH_AUTH_SOCK is only a convenience for the
# shell that ran setup.
PURR_SSH_AUTH_SOCK="${PURR_SSH_AUTH_SOCK:-$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock}"
PURR_GPG_CACHE_TTL="${PURR_GPG_CACHE_TTL:-34560000}"
PURR_OP_RETRY_DELAY="${PURR_OP_RETRY_DELAY:-1}"

if [ -f "$HOME/.purrrc" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.purrrc"
fi

# Obfuscate sensitive key data for safe display.
# Arguments:
#   $1: Input string to obfuscate
# Returns: Obfuscated string (first 4 and last 4 characters)
obfuscate_key() {
  local input=$1
  local visible_chars=4
  local str_length=${#input}
  local middle_length
  local stars

  if [ "$str_length" -le $((visible_chars * 2)) ]; then
    printf '%s\n' "$input"
  else
    local start=${input:0:$visible_chars}
    local end=${input: -$visible_chars}
    middle_length=$((str_length - visible_chars * 2))
    stars=$(printf '%*s' "$middle_length" '' | tr ' ' '*')
    printf '%s\n' "${start}${stars}${end}"
  fi
}

# Print a one-line banner. lolcat is optional and is not animated, so setup
# and check stay fast when it is installed.
# Arguments:
#   $1: Message
purr_banner() {
  if command -v lolcat > /dev/null 2>&1; then
    printf '%s\n' "$1" | lolcat || printf '%s\n' "$1"
  else
    printf '%s\n' "$1"
  fi
}

# Print one status row.
# Arguments:
#   $1: Status word (ok, set, warn, fail)
#   $2: Step label
#   $3: Detail
purr_step() {
  printf '  %-16s %-4s  %s\n' "$2" "$1" "$3"
}

# Print a failure that names the step and the reason.
# Arguments:
#   $1: Step label
#   $2: Reason
purr_fail() {
  printf 'Failed: %s - %s\n' "$1" "$2" >&2
}

# Collapse whitespace and newlines so an error fits on one line.
# Arguments:
#   $1: Text
purr_oneline() {
  printf '%s' "$1" | tr '\n\r' '  ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
}

# Drop item payloads that were held only for the current command.
purr_clear_secrets() {
  unset PURR_ITEM_JSON
  unset PURR_IMPORTED_KEY_ID
  unset PURR_MCP_TOKEN
}

# Print the first matching 1Password field value from an item JSON document.
# Labels and ids are matched case-insensitively, in the order given.
# Empty values are skipped so a later label can win.
# Arguments:
#   stdin: Item JSON
#   $@: Field labels to try
# Returns: 0 and prints the value, or 1 if none match
purr_json_field() {
  perl -MJSON::PP -e '
use strict;
use warnings;
my @want = @ARGV;
local $/;
my $raw = <STDIN>;
exit 1 if !defined $raw || $raw eq "";
my $data = eval { JSON::PP->new->utf8->decode($raw) };
exit 1 if !$data || ref($data) ne "HASH";
my @fields;
push @fields, @{$data->{fields}} if ref($data->{fields}) eq "ARRAY";
if (ref($data->{sections}) eq "ARRAY") {
  for my $section (@{$data->{sections}}) {
    next if ref($section) ne "HASH";
    push @fields, @{$section->{fields}} if ref($section->{fields}) eq "ARRAY";
  }
}
for my $wanted (@want) {
  for my $field (@fields) {
    next if ref($field) ne "HASH";
    my $label = defined $field->{label} ? $field->{label} : "";
    my $id = defined $field->{id} ? $field->{id} : "";
    my $wanted_lc = lc $wanted;
    if (lc($label) eq $wanted_lc || lc($id) eq $wanted_lc) {
      next if !defined $field->{value};
      my $value = "$field->{value}";
      if (length $value) {
        print $value;
        exit 0;
      }
    }
  }
}
exit 1;
' -- "$@"
}

# Print a top-level string from a JSON object.
# Arguments:
#   stdin: JSON object
#   $1: Key
purr_json_value() {
  perl -MJSON::PP -e '
use strict;
use warnings;
my $key = $ARGV[0];
exit 1 if !defined $key || $key eq "";
local $/;
my $raw = <STDIN>;
exit 1 if !defined $raw || $raw eq "";
my $data = eval { JSON::PP->new->utf8->decode($raw) };
exit 1 if !$data || ref($data) ne "HASH";
exit 1 if !exists $data->{$key};
my $value = $data->{$key};
exit 1 if !defined $value || ref($value);
$value = "$value";
exit 1 if $value eq "";
print $value;
exit 0;
' -- "$1"
}

# Return 0 when stdin is a JSON value.
purr_json_ok() {
  perl -MJSON::PP -e '
use strict;
use warnings;
local $/;
my $raw = <STDIN>;
exit 1 if !defined $raw || $raw !~ /\S/;
my $data = eval { JSON::PP->new->utf8->decode($raw) };
exit($data ? 0 : 1);
'
}

# Fetch one 1Password item as JSON. One process means one desktop-app
# connection; callers reuse the document instead of calling op per field.
# Sets PURR_ITEM_JSON. On failure sets PURR_LAST_ERROR.
# Arguments:
#   $1: Item name
#   $2: Vault name
purr_op_item_json_once() {
  local item="$1"
  local vault="$2"
  local err json
  err=$(mktemp)
  PURR_OP_ITEM_GETS=$((${PURR_OP_ITEM_GETS:-0} + 1))
  if [ "$PURR_VERBOSE" = "true" ]; then
    printf 'Reading 1Password item "%s" from vault "%s"\n' "$item" "$vault"
  fi
  if json=$(op item get "$item" --vault "$vault" --format json --reveal 2> "$err"); then
    if [ -z "$json" ] || ! printf '%s' "$json" | purr_json_ok; then
      PURR_ITEM_JSON=""
      PURR_LAST_ERROR="1Password returned invalid JSON for item '${item}' in vault '${vault}': $(purr_oneline "$json")"
      rm -f "$err"
      return 1
    fi
    PURR_ITEM_JSON=$json
    rm -f "$err"
    return 0
  fi
  PURR_ITEM_JSON=""
  PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
  if [ -z "$PURR_LAST_ERROR" ]; then
    PURR_LAST_ERROR="op item get '${item}' failed without an error message"
  fi
  rm -f "$err"
  return 1
}

# Return 0 when the last op error is worth a single retry.
purr_op_error_retriable() {
  printf '%s' "$PURR_LAST_ERROR" | grep -Eqi 'couldn.t connect|could not connect|error initializing client|connecting to desktop app|desktop app'
}

# Return 0 when the item itself is missing (GitHub setup treats that as optional).
purr_op_error_missing_item() {
  printf '%s' "$PURR_LAST_ERROR" | grep -Eqi 'isn.t an item|not found|could not find|couldn.t find|no item|unknown item'
}

# Return 0 when the CLI is asking for an account sign-in.
purr_op_error_needs_signin() {
  printf '%s' "$PURR_LAST_ERROR" | grep -Eqi 'not signed in|unauthorized|must sign in|authentication required'
}

# Launch the 1Password app when it is not running (macOS). No-op elsewhere.
purr_op_try_launch_app() {
  if pgrep -q "1Password" 2> /dev/null; then
    return 0
  fi
  if ! command -v open > /dev/null 2>&1; then
    return 0
  fi
  open -a "1Password" > /dev/null 2>&1 || return 0
  local attempts=0
  while ! pgrep -q "1Password" 2> /dev/null && [ "$attempts" -lt 10 ]; do
    sleep 1
    attempts=$((attempts + 1))
  done
}

# Run `op signin` and eval only the session export it prints.
purr_op_signin() {
  local session err
  err=$(mktemp)
  if ! session=$(op signin 2> "$err"); then
    PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
    rm -f "$err"
    return 1
  fi
  rm -f "$err"
  if [ -n "$session" ]; then
    case "$session" in
      "export OP_SESSION_"*)
        # shellcheck disable=SC2086
        eval "$session"
        ;;
      "OP_SESSION_"*)
        # shellcheck disable=SC2086
        eval "export $session"
        ;;
    esac
  fi
  return 0
}

# Fetch an item once, and retry once if the desktop app connection flakes.
# Arguments:
#   $1: Item name
#   $2: Vault name
purr_op_item_json() {
  local item="$1"
  local vault="$2"
  PURR_ITEM_JSON=""
  PURR_LAST_ERROR=""
  if ! command -v op > /dev/null 2>&1; then
    PURR_LAST_ERROR="1Password CLI (op) is not installed"
    return 1
  fi
  if purr_op_item_json_once "$item" "$vault"; then
    return 0
  fi
  if purr_op_error_retriable; then
    purr_op_try_launch_app
    sleep "${PURR_OP_RETRY_DELAY:-1}"
    if purr_op_item_json_once "$item" "$vault"; then
      return 0
    fi
  fi
  if purr_op_error_needs_signin && [ -t 0 ]; then
    if purr_op_signin && purr_op_item_json_once "$item" "$vault"; then
      return 0
    fi
  fi
  return 1
}

# IdentityAgent value for ~/.ssh/config. Paths under $HOME are written with ~.
purr_identity_agent_config_value() {
  local sock="$PURR_SSH_AUTH_SOCK"
  case "$sock" in
    "$HOME"/*)
      # Leading ~ is intentional so OpenSSH expands IdentityAgent per user.
      printf '%s/%s' '~' "${sock#"$HOME"/}"
      ;;
    *)
      printf '%s' "$sock"
      ;;
  esac
}

# Expand a leading ~ the way OpenSSH does for IdentityAgent.
# Arguments:
#   $1: Socket path from config or the environment
purr_normalize_sock() {
  local value="$1"
  case "$value" in
    \~/*)
      printf '%s/%s' "$HOME" "${value#\~/}"
      ;;
    \~)
      printf '%s' "$HOME"
      ;;
    *)
      printf '%s' "${value%/}"
      ;;
  esac
}

# Print each IdentityAgent value in ~/.ssh/config, one per line.
purr_ssh_identity_agent_values() {
  local file="$HOME/.ssh/config"
  [ -f "$file" ] || return 0
  perl -ne '
use strict;
use warnings;
next if /^\s*#/ || /^\s*$/;
if (/^\s*IdentityAgent(?:\s+|=)\s*(.*)$/) {
  my $v = $1;
  $v =~ s/\s+$//;
  if (length($v) >= 2 && substr($v, 0, 1) eq "\"" && substr($v, -1, 1) eq "\"") {
    $v = substr($v, 1, length($v) - 2);
  }
  print $v, "\n";
}
' "$file"
}

# Return 0 when an IdentityAgent already points at PURR_SSH_AUTH_SOCK.
purr_ssh_has_our_agent() {
  local expected value norm
  expected=$(purr_normalize_sock "$PURR_SSH_AUTH_SOCK")
  expected=${expected%/}
  local agents
  agents=$(purr_ssh_identity_agent_values || true)
  while IFS= read -r value; do
    [ -n "$value" ] || continue
    norm=$(purr_normalize_sock "$value")
    norm=${norm%/}
    if [ "$norm" = "$expected" ]; then
      return 0
    fi
  done <<< "$agents"
  return 1
}

# Print IdentityAgent values that point somewhere other than our socket.
purr_ssh_foreign_agents() {
  local expected value norm
  expected=$(purr_normalize_sock "$PURR_SSH_AUTH_SOCK")
  expected=${expected%/}
  local agents
  agents=$(purr_ssh_identity_agent_values || true)
  while IFS= read -r value; do
    [ -n "$value" ] || continue
    norm=$(purr_normalize_sock "$value")
    norm=${norm%/}
    if [ "$norm" != "$expected" ]; then
      printf '%s\n' "$value"
    fi
  done <<< "$agents"
}

# Create or append the 1Password IdentityAgent block. Does not replace an
# existing different IdentityAgent (OpenSSH keeps the first value it finds).
purr_write_ssh_config() {
  local dir="$HOME/.ssh"
  local file="$dir/config"
  local value escaped
  value=$(purr_identity_agent_config_value)
  escaped=$(printf '%s' "$value" | sed 's/\\/\\\\/g; s/"/\\"/g')
  if ! mkdir -p "$dir"; then
    PURR_LAST_ERROR="could not create ${dir}"
    return 1
  fi
  chmod 700 "$dir" || true
  if [ ! -f "$file" ]; then
    printf '# Added by purr - 1Password SSH agent\nHost *\n  IdentityAgent "%s"\n' "$escaped" > "$file"
    chmod 600 "$file" || true
    return 0
  fi
  printf '\n# Added by purr - 1Password SSH agent\nHost *\n  IdentityAgent "%s"\n' "$escaped" >> "$file"
}

# Ensure ~/.ssh/config sends SSH to the 1Password agent.
# Sets PURR_STEP_STATUS and PURR_STEP_DETAIL on success.
purr_ensure_ssh_config() {
  local foreign shown
  PURR_LAST_ERROR=""
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  if [ -z "${PURR_SSH_AUTH_SOCK:-}" ]; then
    PURR_LAST_ERROR="PURR_SSH_AUTH_SOCK is empty"
    return 1
  fi
  if purr_ssh_has_our_agent; then
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="IdentityAgent already points at the 1Password socket"
    return 0
  fi
  foreign=$(purr_ssh_foreign_agents || true)
  if [ -n "$foreign" ]; then
    shown=$(printf '%s' "$foreign" | tr '\n' ' ' | sed 's/[[:space:]]\+$//')
    PURR_LAST_ERROR="${HOME}/.ssh/config sets IdentityAgent to ${shown}, not ${PURR_SSH_AUTH_SOCK}. Left the file unchanged."
    return 1
  fi
  if ! purr_write_ssh_config; then
    [ -n "$PURR_LAST_ERROR" ] || PURR_LAST_ERROR="could not write ~/.ssh/config"
    return 1
  fi
  PURR_STEP_STATUS="set"
  PURR_STEP_DETAIL="added IdentityAgent to ~/.ssh/config"
  return 0
}

# Ask the 1Password agent for identities. Does not export SSH_AUTH_SOCK.
# Sets PURR_STEP_DETAIL on success and PURR_LAST_ERROR on failure.
purr_ssh_agent_probe() {
  local list rc count
  PURR_LAST_ERROR=""
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  if [ ! -S "$PURR_SSH_AUTH_SOCK" ]; then
    PURR_LAST_ERROR="socket not found at ${PURR_SSH_AUTH_SOCK}. Open 1Password and enable Settings, Developer, Use the SSH agent."
    return 1
  fi
  if ! command -v ssh-add > /dev/null 2>&1; then
    PURR_LAST_ERROR="ssh-add is not installed"
    return 1
  fi
  rc=0
  list=$(SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK" ssh-add -l 2>&1) || rc=$?
  if printf '%s\n' "$list" | grep -qi "no identities"; then
    PURR_LAST_ERROR="connected to ${PURR_SSH_AUTH_SOCK}, but the agent has no identities. Add an SSH key in 1Password."
    return 1
  fi
  if [ "$rc" -ne 0 ] || [ -z "$list" ]; then
    if [ -z "$list" ]; then
      PURR_LAST_ERROR="could not list identities from ${PURR_SSH_AUTH_SOCK}"
    else
      PURR_LAST_ERROR="could not list identities from ${PURR_SSH_AUTH_SOCK}: $(purr_oneline "$list")"
    fi
    return 1
  fi
  count=$(printf '%s\n' "$list" | sed '/^$/d' | wc -l | tr -d ' ')
  PURR_STEP_STATUS="ok"
  PURR_STEP_DETAIL="${count} identities"
  return 0
}

# Probe the agent and export SSH_AUTH_SOCK for the current shell.
purr_ensure_ssh_agent() {
  if ! purr_ssh_agent_probe; then
    return 1
  fi
  export SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK"
  return 0
}

# GnuPG home, honoring GNUPGHOME when the caller set it.
purr_gnupg_dir() {
  if [ -n "${GNUPGHOME:-}" ]; then
    printf '%s' "$GNUPGHOME"
  else
    printf '%s/.gnupg' "$HOME"
  fi
}

# Print the first value of a gpg-agent.conf key.
# Arguments:
#   $1: File
#   $2: Key
purr_conf_first() {
  local file="$1"
  local key="$2"
  [ -f "$file" ] || return 1
  awk -v key="$key" '$1 == key { print $2; exit }' "$file"
}

# Set default-cache-ttl and max-cache-ttl without dropping other agent settings.
# Reloads the agent only when the file changes.
purr_ensure_gpg_ttl() {
  local dir file current_default current_max tmp
  dir=$(purr_gnupg_dir)
  file="$dir/gpg-agent.conf"
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  PURR_LAST_ERROR=""
  current_default=$(purr_conf_first "$file" default-cache-ttl || true)
  current_max=$(purr_conf_first "$file" max-cache-ttl || true)
  if [ "$current_default" = "$PURR_GPG_CACHE_TTL" ] && [ "$current_max" = "$PURR_GPG_CACHE_TTL" ]; then
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="cache TTL already ${PURR_GPG_CACHE_TTL}"
    return 0
  fi
  if ! mkdir -p "$dir"; then
    PURR_LAST_ERROR="could not create ${dir}"
    return 1
  fi
  chmod 700 "$dir" || true
  tmp=$(mktemp)
  if [ -f "$file" ]; then
    awk '$1 == "default-cache-ttl" || $1 == "max-cache-ttl" { next } { print }' "$file" > "$tmp"
  fi
  printf 'default-cache-ttl %s\nmax-cache-ttl %s\n' "$PURR_GPG_CACHE_TTL" "$PURR_GPG_CACHE_TTL" >> "$tmp"
  if ! mv "$tmp" "$file"; then
    rm -f "$tmp"
    PURR_LAST_ERROR="could not update ${file}"
    return 1
  fi
  chmod 600 "$file" || true
  if command -v gpgconf > /dev/null 2>&1; then
    if ! gpgconf --reload gpg-agent > /dev/null 2>&1; then
      gpgconf --kill gpg-agent > /dev/null 2>&1 || true
    fi
  fi
  PURR_STEP_STATUS="set"
  PURR_STEP_DETAIL="set cache TTL to ${PURR_GPG_CACHE_TTL}"
  return 0
}

# Print long secret key ids, one per line.
purr_gpg_secret_ids() {
  command -v gpg > /dev/null 2>&1 || return 1
  gpg --list-secret-keys --with-colons 2> /dev/null | awk -F: '$1 == "sec" && $5 != "" { print $5 }'
}

# Return 0 when the secret keyring contains this key id or fingerprint.
# Arguments:
#   $1: Key id
purr_gpg_has_secret() {
  local key="$1"
  [ -n "$key" ] || return 1
  command -v gpg > /dev/null 2>&1 || return 1
  gpg --list-secret-keys --with-colons "$key" 2> /dev/null | awk -F: '$1 == "sec" { found = 1 } END { exit !found }'
}

# Print the only secret key id. Fails when there are zero or multiple keys.
purr_single_secret_key_id() {
  local ids count
  ids=$(purr_gpg_secret_ids || true)
  [ -n "$ids" ] || return 1
  count=$(printf '%s\n' "$ids" | sed '/^$/d' | wc -l | tr -d ' ')
  [ "$count" = "1" ] || return 1
  printf '%s' "$ids"
}

# Return 0 when a signing key can be chosen without 1Password.
purr_gpg_ready_without_op() {
  local current
  command -v gpg > /dev/null 2>&1 || return 1
  current=$(git config --global user.signingkey 2> /dev/null || true)
  if [ -n "$current" ]; then
    purr_gpg_has_secret "$current"
    return $?
  fi
  purr_single_secret_key_id > /dev/null
}

# Print the key id to configure. Prefers the current signing key, then the
# id just read from 1Password, then the only local secret key.
# Arguments:
#   $1: Preferred key id, may be empty
purr_choose_signing_key() {
  local preferred="$1"
  local current
  current=$(git config --global user.signingkey 2> /dev/null || true)
  if [ -n "$current" ] && purr_gpg_has_secret "$current"; then
    printf '%s' "$current"
    return 0
  fi
  if [ -n "$preferred" ] && purr_gpg_has_secret "$preferred"; then
    printf '%s' "$preferred"
    return 0
  fi
  if purr_single_secret_key_id; then
    return 0
  fi
  return 1
}

# Set user.signingkey, commit.gpgsign, and gpg.program when any of them is missing.
# Leaves an existing executable gpg.program alone.
# Arguments:
#   $1: Preferred key id, may be empty
purr_configure_git_signing() {
  local preferred="$1"
  local key_id gpg_bin current gpgsign gpgprog changed
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  PURR_LAST_ERROR=""
  if ! command -v git > /dev/null 2>&1; then
    PURR_LAST_ERROR="git is not installed"
    return 1
  fi
  gpg_bin=$(command -v gpg || true)
  if [ -z "$gpg_bin" ]; then
    PURR_LAST_ERROR="gpg is not installed"
    return 1
  fi
  if ! key_id=$(purr_choose_signing_key "$preferred"); then
    PURR_LAST_ERROR="no GPG secret key is available to use as user.signingkey"
    return 1
  fi
  current=$(git config --global user.signingkey 2> /dev/null || true)
  gpgsign=$(git config --global commit.gpgsign 2> /dev/null || true)
  gpgprog=$(git config --global gpg.program 2> /dev/null || true)
  changed=0
  if [ "$current" != "$key_id" ]; then
    if ! git config --global user.signingkey "$key_id"; then
      PURR_LAST_ERROR="could not set git user.signingkey"
      return 1
    fi
    changed=1
  fi
  if [ "$gpgsign" != "true" ]; then
    if ! git config --global commit.gpgsign true; then
      PURR_LAST_ERROR="could not set git commit.gpgsign"
      return 1
    fi
    changed=1
  fi
  if [ -z "$gpgprog" ] || [ ! -x "$gpgprog" ]; then
    if ! git config --global gpg.program "$gpg_bin"; then
      PURR_LAST_ERROR="could not set git gpg.program"
      return 1
    fi
    gpgprog=$gpg_bin
    changed=1
  fi
  if [ "$changed" -eq 0 ]; then
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="user.signingkey, commit.gpgsign, and gpg.program already set"
  else
    PURR_STEP_STATUS="set"
    PURR_STEP_DETAIL="signing key $(obfuscate_key "$key_id"), gpg.program ${gpgprog}"
  fi
  return 0
}

# Write armored key text, turning literal \n sequences into newlines.
# Arguments:
#   $1: Destination file
#   stdin: Key material
purr_write_key_file() {
  local dest="$1"
  sed 's/^"//; s/"$//; s/\\n/\n/g' > "$dest"
  printf '\n' >> "$dest"
}

# Import one key file. Pass an empty passphrase for public keys.
# Arguments:
#   $1: Key file
#   $2: Passphrase, may be empty
purr_gpg_import_file() {
  local file="$1"
  local password="$2"
  local err pf rc
  err=$(mktemp)
  rc=0
  if [ -n "$password" ]; then
    pf=$(mktemp)
    chmod 600 "$pf" || true
    printf '%s' "$password" > "$pf"
    if gpg --batch --yes --pinentry-mode loopback --passphrase-file "$pf" --import "$file" > "$err" 2>&1; then
      rc=0
    else
      rc=$?
    fi
    rm -f "$pf"
  else
    if gpg --batch --yes --import "$file" > "$err" 2>&1; then
      rc=0
    else
      rc=$?
    fi
  fi
  if [ "$rc" -ne 0 ]; then
    PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
    rm -f "$err"
    return 1
  fi
  rm -f "$err"
  return 0
}

# Sign a throwaway file with loopback so a bad passphrase fails here, not later
# in an editor. Removes the secret key again when the test fails.
# Arguments:
#   $1: Key id
#   $2: Passphrase, may be empty
purr_sign_test_with_passphrase() {
  local key_id="$1"
  local password="$2"
  local data sig pf err
  data=$(mktemp)
  sig=$(mktemp)
  pf=$(mktemp)
  err=$(mktemp)
  chmod 600 "$pf" || true
  printf 'test\n' > "$data"
  printf '%s' "$password" > "$pf"
  if [ -n "$password" ]; then
    if gpg --batch --yes --pinentry-mode loopback --passphrase-file "$pf" \
      --local-user "$key_id" --output "$sig" --sign "$data" > "$err" 2>&1; then
      rm -f "$data" "$sig" "$pf" "$err"
      return 0
    fi
  elif gpg --batch --yes --pinentry-mode loopback --local-user "$key_id" \
    --output "$sig" --sign "$data" > "$err" 2>&1; then
    rm -f "$data" "$sig" "$pf" "$err"
    return 0
  fi
  PURR_LAST_ERROR="signing with the imported key failed: $(purr_oneline "$(cat "$err" 2> /dev/null || true)")"
  rm -f "$data" "$sig" "$pf" "$err"
  gpg --batch --yes --delete-secret-keys "$key_id" > /dev/null 2>&1 || true
  return 1
}

# Import the GPG item in PURR_ITEM_JSON. Skips the import when that key is
# already in the secret keyring. Sets PURR_IMPORTED_KEY_ID.
purr_import_gpg_item() {
  local json key_id password public_key private_key pub_file priv_file
  json=$PURR_ITEM_JSON
  unset PURR_ITEM_JSON
  key_id=$(printf '%s' "$json" | purr_json_field key_id || true)
  password=$(printf '%s' "$json" | purr_json_field password || true)
  public_key=$(printf '%s' "$json" | purr_json_field public_key || true)
  private_key=$(printf '%s' "$json" | purr_json_field private_key || true)
  json=""
  if [ -z "$key_id" ]; then
    PURR_LAST_ERROR="1Password item '${PURR_GPG_ITEM}' in vault '${PURR_VAULT_NAME}' has no key_id field"
    return 1
  fi
  if [ -z "$private_key" ]; then
    PURR_LAST_ERROR="1Password item '${PURR_GPG_ITEM}' in vault '${PURR_VAULT_NAME}' has no private_key field"
    return 1
  fi
  if purr_gpg_has_secret "$key_id"; then
    PURR_IMPORTED_KEY_ID=$key_id
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="secret key $(obfuscate_key "$key_id") already in the keyring"
    password=""
    private_key=""
    public_key=""
    return 0
  fi
  priv_file=$(mktemp)
  chmod 600 "$priv_file" || true
  if [ -n "$public_key" ]; then
    pub_file=$(mktemp)
    chmod 600 "$pub_file" || true
    printf '%s' "$public_key" | purr_write_key_file "$pub_file"
    if ! purr_gpg_import_file "$pub_file" ""; then
      rm -f "$pub_file" "$priv_file"
      PURR_LAST_ERROR="public key import failed: $(purr_oneline "$PURR_LAST_ERROR")"
      password=""
      private_key=""
      public_key=""
      return 1
    fi
    rm -f "$pub_file"
  fi
  public_key=""
  printf '%s' "$private_key" | purr_write_key_file "$priv_file"
  private_key=""
  if ! purr_gpg_import_file "$priv_file" "$password"; then
    rm -f "$priv_file"
    PURR_LAST_ERROR="private key import failed: $(purr_oneline "$PURR_LAST_ERROR")"
    password=""
    return 1
  fi
  rm -f "$priv_file"
  if ! purr_gpg_has_secret "$key_id"; then
    password=""
    PURR_LAST_ERROR="imported the 1Password key but gpg does not list secret key ${key_id}"
    return 1
  fi
  if ! purr_sign_test_with_passphrase "$key_id" "$password"; then
    password=""
    return 1
  fi
  password=""
  PURR_IMPORTED_KEY_ID=$key_id
  PURR_STEP_STATUS="set"
  PURR_STEP_DETAIL="imported secret key $(obfuscate_key "$key_id") from 1Password"
  return 0
}

# Remove one secret key. Uses the signing key when given, otherwise the only
# secret key, otherwise the first one.
# Arguments:
#   $1: Key id, may be empty
purr_remove_secret_key() {
  local key="$1"
  local err
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  PURR_LAST_ERROR=""
  if [ -z "$key" ]; then
    key=$(purr_single_secret_key_id || true)
  fi
  if [ -z "$key" ]; then
    key=$(purr_gpg_secret_ids | head -n 1 || true)
  fi
  if [ -z "$key" ]; then
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="no secret key to remove"
    return 0
  fi
  err=$(mktemp)
  if gpg --batch --yes --delete-secret-keys "$key" > "$err" 2>&1; then
    rm -f "$err"
    PURR_STEP_STATUS="set"
    PURR_STEP_DETAIL="removed secret key $(obfuscate_key "$key")"
    return 0
  fi
  PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
  rm -f "$err"
  return 1
}

# Print the gh CLI token when gh is installed and authenticated.
purr_gh_token() {
  local token
  command -v gh > /dev/null 2>&1 || return 1
  token=$(gh auth token 2> /dev/null) || return 1
  [ -n "$token" ] || return 1
  printf '%s' "$token"
}

# Print the GitHub token already stored in ~/.cursor/mcp.json.
purr_mcp_github_token() {
  local file="$HOME/.cursor/mcp.json"
  [ -f "$file" ] || return 1
  perl -MJSON::PP -e '
use strict;
use warnings;
my $file = $ARGV[0];
exit 1 if !defined $file || !-f $file;
open my $fh, "<:raw", $file or exit 1;
local $/;
my $raw = <$fh>;
close $fh;
exit 1 if !defined $raw || $raw !~ /\S/;
my $data = eval { JSON::PP->new->utf8->decode($raw) };
exit 1 if !$data || ref($data) ne "HASH";
my $servers = $data->{mcpServers};
exit 1 if ref($servers) ne "HASH";
my $github = $servers->{github};
exit 1 if ref($github) ne "HASH";
my $env = $github->{env};
exit 1 if ref($env) ne "HASH";
my $token = $env->{GITHUB_PERSONAL_ACCESS_TOKEN};
exit 1 if !defined $token || $token eq "";
print $token;
exit 0;
' -- "$file"
}

# Merge a GitHub MCP server into ~/.cursor/mcp.json without replacing other servers.
# Exit 10 from perl means the token is already present and the file is left alone.
# Arguments:
#   $1: Token
purr_mcp_write_token() {
  local token="$1"
  local file="$HOME/.cursor/mcp.json"
  local tmp err rc
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  PURR_LAST_ERROR=""
  if [ -z "$token" ]; then
    PURR_LAST_ERROR="no GitHub token to write"
    return 1
  fi
  if ! mkdir -p "$HOME/.cursor"; then
    PURR_LAST_ERROR="could not create ~/.cursor"
    return 1
  fi
  tmp=$(mktemp)
  err=$(mktemp)
  if PURR_MCP_TOKEN="$token" perl -MJSON::PP -e '
use strict;
use warnings;
my $file = $ARGV[0];
my $token = $ENV{PURR_MCP_TOKEN};
die "missing token\n" if !defined $token || $token eq "";
my $data = {};
if (defined $file && $file ne "" && -f $file) {
  open my $fh, "<:raw", $file or die "could not read $file: $!\n";
  local $/;
  my $raw = <$fh>;
  close $fh;
  if (defined $raw && $raw =~ /\S/) {
    my $decoded = eval { JSON::PP->new->utf8->decode($raw) };
    if (!$decoded || ref($decoded) ne "HASH") {
      die "not valid JSON\n";
    }
    $data = $decoded;
  }
}
if (exists $data->{mcpServers} && ref($data->{mcpServers}) ne "HASH") {
  die "mcpServers is not a JSON object\n";
}
$data->{mcpServers} ||= {};
my $github = $data->{mcpServers}{github};
if (defined $github && ref($github) ne "HASH") {
  die "mcpServers.github is not a JSON object\n";
}
if (ref($github) eq "HASH") {
  if (defined $github->{env} && ref($github->{env}) ne "HASH") {
    die "mcpServers.github.env is not a JSON object\n";
  }
  $github->{env} ||= {};
  my $existing = $github->{env}{GITHUB_PERSONAL_ACCESS_TOKEN};
  $existing = "" if !defined $existing;
  if ($existing eq $token && defined $github->{command} && $github->{command} ne "") {
    exit 10;
  }
  $github->{env}{GITHUB_PERSONAL_ACCESS_TOKEN} = $token;
  if (!defined $github->{command} || $github->{command} eq "") {
    $github->{command} = "npx";
    $github->{args} = ["-y", "\@modelcontextprotocol/server-github"];
  }
} else {
  $data->{mcpServers}{github} = {
    command => "npx",
    args => ["-y", "\@modelcontextprotocol/server-github"],
    env => { GITHUB_PERSONAL_ACCESS_TOKEN => $token },
  };
}
print JSON::PP->new->utf8->pretty->canonical->encode($data);
exit 0;
' -- "$file" > "$tmp" 2> "$err"; then
    rc=0
  else
    rc=$?
  fi
  unset PURR_MCP_TOKEN
  if [ "$rc" -eq 10 ]; then
    rm -f "$tmp" "$err"
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="GitHub token already in ~/.cursor/mcp.json"
    return 0
  fi
  if [ "$rc" -ne 0 ]; then
    PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
    rm -f "$tmp" "$err"
    return 1
  fi
  if ! mv "$tmp" "$file"; then
    PURR_LAST_ERROR="could not update ~/.cursor/mcp.json"
    rm -f "$tmp" "$err"
    return 1
  fi
  chmod 600 "$file" || true
  rm -f "$err"
  PURR_STEP_STATUS="set"
  PURR_STEP_DETAIL="updated the github server in ~/.cursor/mcp.json"
  return 0
}

# Remove only the GitHub MCP server. Deletes the file when that was its only entry.
# Leaves an invalid file untouched instead of erasing unrelated configuration.
purr_mcp_remove_github() {
  local file="$HOME/.cursor/mcp.json"
  local tmp err rc
  PURR_STEP_STATUS=""
  PURR_STEP_DETAIL=""
  PURR_LAST_ERROR=""
  if [ ! -e "$file" ]; then
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="${HOME}/.cursor/mcp.json is not present"
    return 0
  fi
  tmp=$(mktemp)
  err=$(mktemp)
  if perl -MJSON::PP -e '
use strict;
use warnings;
my $file = $ARGV[0];
exit 10 if !defined $file || !-f $file;
open my $fh, "<:raw", $file or die "could not read $file: $!\n";
local $/;
my $raw = <$fh>;
close $fh;
exit 11 if !defined $raw || $raw !~ /\S/;
my $data = eval { JSON::PP->new->utf8->decode($raw) };
if (!$data || ref($data) ne "HASH") {
  die "not valid JSON\n";
}
if (exists $data->{mcpServers} && ref($data->{mcpServers}) ne "HASH") {
  die "mcpServers is not a JSON object\n";
}
my $servers = $data->{mcpServers};
if (ref($servers) ne "HASH" || !exists $servers->{github}) {
  exit 10;
}
delete $servers->{github};
if (!keys %{$servers}) {
  delete $data->{mcpServers};
}
if (!keys %{$data}) {
  exit 11;
}
print JSON::PP->new->utf8->pretty->canonical->encode($data);
exit 0;
' -- "$file" > "$tmp" 2> "$err"; then
    rc=0
  else
    rc=$?
  fi
  if [ "$rc" -eq 10 ]; then
    rm -f "$tmp" "$err"
    PURR_STEP_STATUS="ok"
    PURR_STEP_DETAIL="GitHub server was not in ~/.cursor/mcp.json"
    return 0
  fi
  if [ "$rc" -eq 11 ]; then
    rm -f "$file" "$tmp" "$err"
    PURR_STEP_STATUS="set"
    PURR_STEP_DETAIL="removed ~/.cursor/mcp.json"
    return 0
  fi
  if [ "$rc" -ne 0 ]; then
    PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
    rm -f "$tmp" "$err"
    return 1
  fi
  if ! mv "$tmp" "$file"; then
    PURR_LAST_ERROR="could not update ~/.cursor/mcp.json"
    rm -f "$tmp" "$err"
    return 1
  fi
  chmod 600 "$file" || true
  rm -f "$err"
  PURR_STEP_STATUS="set"
  PURR_STEP_DETAIL="removed the GitHub server from ~/.cursor/mcp.json"
  return 0
}

# Store HTTPS GitHub credentials in the macOS keychain when that helper exists.
# Arguments:
#   $1: Username
#   $2: Token
purr_store_osxkeychain() {
  local user="$1"
  local token="$2"
  local err
  err=$(mktemp)
  if printf 'protocol=https\nhost=github.com\nusername=%s\npassword=%s\n' "$user" "$token" | git credential-osxkeychain store > "$err" 2>&1; then
    rm -f "$err"
    return 0
  fi
  if grep -q "not a git command" "$err"; then
    rm -f "$err"
    return 0
  fi
  PURR_LAST_ERROR=$(cat "$err" 2> /dev/null || true)
  rm -f "$err"
  return 1
}

# Update mcp.json and report a warning without failing setup when the file is unsafe to edit.
# Arguments:
#   $1: Token
purr_github_finish_mcp() {
  local token="$1"
  if purr_mcp_write_token "$token"; then
    purr_step "$PURR_STEP_STATUS" "Cursor MCP" "$PURR_STEP_DETAIL"
    return 0
  fi
  purr_step warn "Cursor MCP" "left ~/.cursor/mcp.json unchanged: $(purr_oneline "$PURR_LAST_ERROR")"
  return 0
}

# Fill in git identity and a GitHub token.
# Prefers `gh auth token`. Falls back to one 1Password read of the GitHub item.
# Reuses a token already stored in mcp.json so a later setup does not prompt.
purr_ensure_github() {
  local token="" name="" email="" source="" json
  local op_user="" op_email="" op_token="" changed=0
  local user_json="" login_from_gh="" email_from_gh="" stored=""
  PURR_LAST_ERROR=""
  if token=$(purr_gh_token); then
    source="gh"
  else
    token=""
  fi

  name=$(git config --global user.name 2> /dev/null || true)
  email=$(git config --global user.email 2> /dev/null || true)

  if [ "$source" = "gh" ]; then
    if [ -z "$name" ] || [ -z "$email" ]; then
      user_json=$(gh api user 2> /dev/null || true)
      if [ -n "$user_json" ]; then
        login_from_gh=$(printf '%s' "$user_json" | purr_json_value login || true)
        email_from_gh=$(printf '%s' "$user_json" | purr_json_value email || true)
        if [ -z "$name" ] && [ -n "$login_from_gh" ]; then
          git config --global user.name "$login_from_gh" || true
          name=$login_from_gh
        fi
        if [ -z "$email" ] && [ -n "$email_from_gh" ]; then
          git config --global user.email "$email_from_gh" || true
          email=$email_from_gh
        fi
      fi
    fi
    export GITHUB_TOKEN="$token"
    if [ -n "$name" ] && [ -n "$email" ]; then
      purr_step ok "GitHub" "token from gh; git user ${name}"
    else
      purr_step warn "GitHub" "token from gh; git user.name or user.email is still empty"
    fi
    purr_github_finish_mcp "$token"
    token=""
    return 0
  fi

  if [ -n "$name" ] && [ -n "$email" ]; then
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      purr_step ok "GitHub" "git user already set; using GITHUB_TOKEN from this shell"
      purr_github_finish_mcp "$GITHUB_TOKEN"
      return 0
    fi
    if stored=$(purr_mcp_github_token); then
      export GITHUB_TOKEN="$stored"
      purr_step ok "GitHub" "git user already set; reused the token in ~/.cursor/mcp.json"
      stored=""
      return 0
    fi
  fi

  if ! purr_op_item_json "$PURR_GITHUB_ITEM" "$PURR_VAULT_NAME"; then
    if purr_op_error_missing_item; then
      purr_step warn "GitHub" "gh is not authenticated and 1Password item '${PURR_GITHUB_ITEM}' was not found; skipped"
      return 0
    fi
    purr_step warn "GitHub" "skipped 1Password fallback: $(purr_oneline "$PURR_LAST_ERROR")"
    return 0
  fi

  json=$PURR_ITEM_JSON
  unset PURR_ITEM_JSON
  op_user=$(printf '%s' "$json" | purr_json_field username user login || true)
  op_email=$(printf '%s' "$json" | purr_json_field email mail "email address" || true)
  op_token=$(printf '%s' "$json" | purr_json_field pat token "access token" "personal access token" password || true)
  json=""

  if [ -z "$op_user" ] || [ -z "$op_email" ] || [ -z "$op_token" ]; then
    purr_step warn "GitHub" "1Password item '${PURR_GITHUB_ITEM}' is missing a username, email, or token"
    return 0
  fi

  if [ -z "$name" ]; then
    if ! git config --global user.name "$op_user"; then
      purr_step warn "GitHub" "could not set git user.name"
      op_token=""
      return 0
    fi
    changed=1
  fi
  if [ -z "$email" ]; then
    if ! git config --global user.email "$op_email"; then
      purr_step warn "GitHub" "could not set git user.email"
      op_token=""
      return 0
    fi
    changed=1
  fi
  export GITHUB_TOKEN="$op_token"
  if ! purr_store_osxkeychain "$op_user" "$op_token"; then
    purr_step warn "GitHub" "token exported, but the macOS keychain update failed: $(purr_oneline "$PURR_LAST_ERROR")"
  elif [ "$changed" -eq 1 ]; then
    purr_step set "GitHub" "git user from 1Password; token stored for this shell"
  else
    purr_step ok "GitHub" "token from 1Password; git user already set"
  fi
  purr_github_finish_mcp "$op_token"
  op_token=""
  return 0
}

# Sign a throwaway string without prompting. Used by `purr check`.
# Arguments:
#   $1: Key id
purr_try_test_sign() {
  local key="$1"
  printf 'purr-check\n' | gpg --batch --yes --pinentry-mode cancel --local-user "$key" --clearsign > /dev/null 2>&1
}

# Idempotent machine setup. Contacts 1Password only for secrets that are not
# already available locally or via gh.
# Arguments:
#   $1: "true" or "false"
purr_setup_body() {
  local verbose="$1"
  local failed=0
  local preferred=""
  local gpg_ok=0
  local shown=""
  PURR_VERBOSE=$verbose
  PURR_OP_ITEM_GETS=0

  if ! purr_ensure_ssh_config; then
    purr_fail "SSH config" "$PURR_LAST_ERROR"
    failed=1
  else
    purr_step "$PURR_STEP_STATUS" "SSH config" "$PURR_STEP_DETAIL"
  fi

  if ! purr_ensure_ssh_agent; then
    purr_fail "SSH agent" "$PURR_LAST_ERROR"
    failed=1
  else
    purr_step "$PURR_STEP_STATUS" "SSH agent" "$PURR_STEP_DETAIL"
  fi

  if ! purr_ensure_gpg_ttl; then
    purr_fail "GPG cache" "$PURR_LAST_ERROR"
    failed=1
  else
    purr_step "$PURR_STEP_STATUS" "GPG cache" "$PURR_STEP_DETAIL"
  fi

  if ! command -v gpg > /dev/null 2>&1; then
    purr_fail "GPG key" "gpg is not installed (install GnuPG, for example: brew install gnupg)"
    failed=1
  elif purr_gpg_ready_without_op; then
    shown=$(git config --global user.signingkey 2> /dev/null || true)
    if [ -z "$shown" ]; then
      shown=$(purr_single_secret_key_id || true)
    fi
    if [ -n "$shown" ]; then
      purr_step ok "GPG key" "secret key $(obfuscate_key "$shown") already in the keyring"
    else
      purr_step ok "GPG key" "secret key already in the keyring"
    fi
    gpg_ok=1
  elif ! purr_op_item_json "$PURR_GPG_ITEM" "$PURR_VAULT_NAME"; then
    purr_fail "GPG key" "could not read 1Password item '${PURR_GPG_ITEM}' in vault '${PURR_VAULT_NAME}': $(purr_oneline "$PURR_LAST_ERROR")"
    failed=1
  elif ! purr_import_gpg_item; then
    purr_fail "GPG key" "$PURR_LAST_ERROR"
    failed=1
  else
    preferred=$PURR_IMPORTED_KEY_ID
    purr_step "$PURR_STEP_STATUS" "GPG key" "$PURR_STEP_DETAIL"
    gpg_ok=1
  fi

  if [ "$gpg_ok" -eq 1 ]; then
    if ! purr_configure_git_signing "$preferred"; then
      purr_fail "Git signing" "$PURR_LAST_ERROR"
      failed=1
    else
      purr_step "$PURR_STEP_STATUS" "Git signing" "$PURR_STEP_DETAIL"
    fi
  fi

  purr_ensure_github || true

  if [ "$verbose" = "true" ]; then
    printf '1Password item reads: %s\n' "${PURR_OP_ITEM_GETS:-0}"
  fi

  if [ "$failed" -ne 0 ]; then
    printf 'Setup incomplete.\n' >&2
    return 1
  fi

  printf '\n'
  purr_banner "ᓚᘏᗢ purr"
  return 0
}

# Run setup and clear item payloads before returning.
# Arguments:
#   $1: "true" or "false"
purr_setup() {
  local rc=0
  purr_setup_body "$1" || rc=$?
  purr_clear_secrets
  return "$rc"
}

# Local health check. Does not call 1Password or change configuration.
# A test signature runs only with pinentry cancelled, so it cannot prompt.
# Arguments:
#   $1: "true" or "false"
purr_check() {
  local verbose="$1"
  local failed=0
  local warned=0
  local signing="" gpgsign="" gpgprog="" git_problem=""
  local sign_key="" dir file cache_default cache_max
  PURR_OP_ITEM_GETS=0

  if purr_ssh_has_our_agent; then
    purr_step ok "SSH config" "IdentityAgent points at the 1Password socket"
  else
    purr_step fail "SSH config" "IdentityAgent for the 1Password socket is not set in ~/.ssh/config"
    failed=$((failed + 1))
  fi

  if purr_ssh_agent_probe; then
    purr_step ok "SSH agent" "$PURR_STEP_DETAIL"
  else
    purr_step fail "SSH agent" "$PURR_LAST_ERROR"
    failed=$((failed + 1))
  fi

  signing=$(git config --global user.signingkey 2> /dev/null || true)
  if [ -n "$signing" ] && purr_gpg_has_secret "$signing"; then
    purr_step ok "GPG key" "$(obfuscate_key "$signing") is in the secret keyring"
  elif purr_single_secret_key_id > /dev/null; then
    purr_step warn "GPG key" "a secret key is present but it is not selected as user.signingkey"
    warned=$((warned + 1))
  else
    purr_step fail "GPG key" "no usable secret key in the keyring"
    failed=$((failed + 1))
  fi

  gpgsign=$(git config --global commit.gpgsign 2> /dev/null || true)
  gpgprog=$(git config --global gpg.program 2> /dev/null || true)
  git_problem=""
  if [ -z "$signing" ]; then
    git_problem="user.signingkey is not set"
  elif [ "$gpgsign" != "true" ]; then
    git_problem="commit.gpgsign is not true"
  elif [ -z "$gpgprog" ]; then
    git_problem="gpg.program is not set"
  elif [ ! -x "$gpgprog" ]; then
    git_problem="gpg.program is not executable (${gpgprog})"
  elif ! purr_gpg_has_secret "$signing"; then
    git_problem="signing key ${signing} is not in the secret keyring"
  fi
  if [ -z "$git_problem" ]; then
    purr_step ok "Git signing" "gpgsign=true program=${gpgprog}"
  else
    purr_step fail "Git signing" "$git_problem"
    failed=$((failed + 1))
  fi

  dir=$(purr_gnupg_dir)
  file="$dir/gpg-agent.conf"
  cache_default=$(purr_conf_first "$file" default-cache-ttl || true)
  cache_max=$(purr_conf_first "$file" max-cache-ttl || true)
  if [ "$cache_default" = "$PURR_GPG_CACHE_TTL" ] && [ "$cache_max" = "$PURR_GPG_CACHE_TTL" ]; then
    purr_step ok "GPG cache" "TTL ${PURR_GPG_CACHE_TTL}"
  elif [ -z "$cache_default" ] && [ -z "$cache_max" ]; then
    purr_step warn "GPG cache" "cache TTL is not set in gpg-agent.conf"
    warned=$((warned + 1))
  else
    purr_step warn "GPG cache" "TTL is default=${cache_default:-unset} max=${cache_max:-unset}; expected ${PURR_GPG_CACHE_TTL}"
    warned=$((warned + 1))
  fi

  sign_key=$signing
  if [ -z "$sign_key" ]; then
    sign_key=$(purr_single_secret_key_id || true)
  fi
  if [ -z "$sign_key" ] || ! purr_gpg_has_secret "$sign_key"; then
    purr_step warn "Test signature" "skipped; no secret key to sign with"
    warned=$((warned + 1))
  elif purr_try_test_sign "$sign_key"; then
    purr_step ok "Test signature" "signed a throwaway string without prompting"
  else
    purr_step warn "Test signature" "skipped; passphrase is not cached and signing would prompt"
    warned=$((warned + 1))
  fi

  if purr_gh_token > /dev/null; then
    purr_step ok "GitHub" "authenticated via gh"
  elif [ -n "${GITHUB_TOKEN:-}" ]; then
    purr_step ok "GitHub" "GITHUB_TOKEN is set in this shell"
  else
    purr_step warn "GitHub" "gh is not authenticated and GITHUB_TOKEN is unset"
    warned=$((warned + 1))
  fi

  if [ "$verbose" = "true" ]; then
    printf '1Password item reads: %s\n' "${PURR_OP_ITEM_GETS:-0}"
  fi

  if [ "$failed" -ne 0 ]; then
    printf '%s check(s) failed.\n' "$failed"
    return 1
  fi
  if [ "$warned" -ne 0 ]; then
    printf 'Checks passed with warnings.\n'
    return 0
  fi
  printf 'All checks passed.\n'
  return 0
}

# Sign out of the 1Password CLI and remove local signing material.
# Keeps the IdentityAgent line in ~/.ssh/config.
# Arguments:
#   $1: "true" or "false"
purr_lock() {
  local verbose="$1"
  local signing err
  PURR_VERBOSE=$verbose
  signing=$(git config --global user.signingkey 2> /dev/null || true)

  if ! command -v op > /dev/null 2>&1; then
    purr_step warn "1Password" "op is not installed; skipped signout"
  else
    err=$(mktemp)
    if op signout --all > "$err" 2>&1; then
      rm -f "$err"
      purr_step ok "1Password" "signed out of the CLI"
    else
      purr_step warn "1Password" "signout failed: $(purr_oneline "$(cat "$err" 2> /dev/null || true)")"
      rm -f "$err"
    fi
  fi

  unset SSH_AUTH_SOCK
  unset SSH_AGENT_PID
  purr_step ok "SSH agent" "unset SSH_AUTH_SOCK; IdentityAgent in ~/.ssh/config kept"

  if purr_remove_secret_key "$signing"; then
    purr_step "$PURR_STEP_STATUS" "GPG key" "$PURR_STEP_DETAIL"
  else
    purr_step warn "GPG key" "could not remove secret key: $(purr_oneline "$PURR_LAST_ERROR")"
  fi
  if command -v gpgconf > /dev/null 2>&1; then
    gpgconf --kill gpg-agent > /dev/null 2>&1 || true
  fi

  git config --global --unset user.signingkey > /dev/null 2>&1 || true
  git config --global --unset commit.gpgsign > /dev/null 2>&1 || true
  purr_step ok "Git signing" "cleared user.signingkey and commit.gpgsign"

  unset GITHUB_TOKEN
  if purr_mcp_remove_github; then
    purr_step "$PURR_STEP_STATUS" "GitHub" "$PURR_STEP_DETAIL"
  else
    purr_step warn "GitHub" "left ~/.cursor/mcp.json unchanged: $(purr_oneline "$PURR_LAST_ERROR")"
  fi

  purr_banner "System locked"
  purr_banner "ᓚᘏᗢ hiss"
}

# Load SSH by writing IdentityAgent (if absent) and exporting SSH_AUTH_SOCK.
# Arguments:
#   $1: "true" or "false"
load_ssh_key() {
  local verbose="${1:-false}"
  PURR_VERBOSE=$verbose
  if ! purr_ensure_ssh_config; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
    return 1
  fi
  if ! purr_ensure_ssh_agent; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
    return 1
  fi
  return 0
}

# Unset SSH agent variables for this shell. Does not edit ~/.ssh/config.
# Arguments:
#   $1: "true" or "false"
unload_ssh_key() {
  local verbose="${1:-false}"
  if [ "$verbose" = "true" ]; then
    printf 'SSH_AUTH_SOCK was: %s\n' "${SSH_AUTH_SOCK:-}"
  fi
  unset SSH_AUTH_SOCK
  unset SSH_AGENT_PID
  if [ "$verbose" = "true" ]; then
    printf 'SSH agent environment variables unset.\n'
  fi
  return 0
}

# Import the GPG item with a single 1Password read and configure Git signing.
# Arguments:
#   $1: "true" or "false"
load_gpg_key() {
  local verbose="${1:-false}"
  local rc=0
  PURR_VERBOSE=$verbose
  if ! command -v gpg > /dev/null 2>&1; then
    [ "$verbose" = "true" ] && printf '%s\n' "gpg is not installed"
    return 1
  fi
  purr_ensure_gpg_ttl || true
  if ! purr_op_item_json "$PURR_GPG_ITEM" "$PURR_VAULT_NAME"; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
    purr_clear_secrets
    return 1
  fi
  if ! purr_import_gpg_item; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
    purr_clear_secrets
    return 1
  fi
  if ! purr_configure_git_signing "${PURR_IMPORTED_KEY_ID:-}"; then
    rc=1
  fi
  purr_clear_secrets
  return "$rc"
}

# Remove the configured secret key and stop the agent.
# Arguments:
#   $1: "true" or "false"
unload_gpg_key() {
  local verbose="${1:-false}"
  local signing
  signing=$(git config --global user.signingkey 2> /dev/null || true)
  if ! purr_remove_secret_key "$signing"; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
  elif [ "$verbose" = "true" ]; then
    printf '%s\n' "$PURR_STEP_DETAIL"
  fi
  if command -v gpgconf > /dev/null 2>&1; then
    gpgconf --kill gpg-agent > /dev/null 2>&1 || true
  fi
  return 0
}

# Check SSH, GPG, Git signing, and GitHub without calling 1Password.
# Arguments:
#   $1: "true" or "false"
check_keys() {
  purr_check "${1:-false}"
}

# Configure Git signing from the local keyring, or from one key_id read.
# Arguments:
#   $1: "true" or "false"
enable_git_signing() {
  local verbose="${1:-false}"
  local json key_id gpg_bin
  PURR_VERBOSE=$verbose
  if purr_configure_git_signing ""; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_STEP_DETAIL"
    return 0
  fi
  if ! purr_op_item_json "$PURR_GPG_ITEM" "$PURR_VAULT_NAME"; then
    [ "$verbose" = "true" ] && printf '%s\n' "$PURR_LAST_ERROR"
    purr_clear_secrets
    return 1
  fi
  json=$PURR_ITEM_JSON
  unset PURR_ITEM_JSON
  key_id=$(printf '%s' "$json" | purr_json_field key_id || true)
  json=""
  if [ -z "$key_id" ]; then
    [ "$verbose" = "true" ] && printf '%s\n' "No GPG key ID found in 1Password."
    purr_clear_secrets
    return 1
  fi
  git config --global user.signingkey "$key_id" || {
    purr_clear_secrets
    return 1
  }
  git config --global commit.gpgsign true || {
    purr_clear_secrets
    return 1
  }
  gpg_bin=$(command -v gpg || true)
  if [ -n "$gpg_bin" ]; then
    git config --global gpg.program "$gpg_bin" || true
  fi
  [ "$verbose" = "true" ] && printf 'Git GPG signing enabled with key: %s\n' "$key_id"
  purr_clear_secrets
  return 0
}

# Clear Git commit signing. Leaves gpg.program in place.
# Arguments:
#   $1: "true" or "false"
disable_git_signing() {
  local verbose="${1:-false}"
  [ "$verbose" = "true" ] && printf '%s\n' "Disabling Git GPG signing..."
  git config --global --unset user.signingkey > /dev/null 2>&1 || true
  git config --global --unset commit.gpgsign > /dev/null 2>&1 || true
  [ "$verbose" = "true" ] && printf '%s\n' "Git GPG signing disabled."
  return 0
}

# Confirm the 1Password CLI can talk to an account, signing in on a terminal if needed.
# Arguments:
#   $1: "true" or "false"
check_1password() {
  local verbose="${1:-false}"
  local attempts=0
  if ! command -v op > /dev/null 2>&1; then
    printf '%s\n' "1Password CLI (op) is not installed." >&2
    return 1
  fi
  if op account get > /dev/null 2>&1; then
    [ "$verbose" = "true" ] && printf '%s\n' "1Password is running and authenticated"
    return 0
  fi
  if ! pgrep -q "1Password" 2> /dev/null && command -v open > /dev/null 2>&1; then
    open -a "1Password" > /dev/null 2>&1 || true
    while ! pgrep -q "1Password" 2> /dev/null && [ "$attempts" -lt 10 ]; do
      sleep 1
      attempts=$((attempts + 1))
    done
  fi
  if [ -t 0 ] && purr_op_signin && op account get > /dev/null 2>&1; then
    [ "$verbose" = "true" ] && printf '%s\n' "1Password is running and authenticated"
    return 0
  fi
  printf '%s\n' "Could not authenticate with 1Password CLI. Start the 1Password app, enable CLI integration, and try again." >&2
  return 1
}

# Configure GitHub from gh when possible, otherwise from one 1Password item read.
# Arguments:
#   $1: "true" or "false"
setup_github_credentials() {
  local verbose="${1:-false}"
  PURR_VERBOSE=$verbose
  purr_ensure_github
  purr_clear_secrets
  return 0
}

# purr command.
# Commands:
#   (none) or setup - idempotent machine setup
#   check           - local health check
#   lock            - unload signing material and sign out of 1Password
# Options:
#   -v  verbose
#   -h  help
purr() {
  local verbose=false
  local command=""
  PURR_VERBOSE=false
  PURR_OP_ITEM_GETS=0

  print_help() {
    cat << 'EOF'
Usage: purr [command] [-v]

Commands:
  (none)    Idempotent setup for this machine (SSH agent, GPG, Git signing, GitHub)
  setup     Same as running purr with no command
  check     Local health check of SSH, GPG, Git signing, and GitHub
  lock      Unload GPG keys, clear Git signing, and sign out of 1Password
  -h        Show this help message

Options:
  -v        Verbose mode

Setup writes the 1Password IdentityAgent into ~/.ssh/config when it is absent,
imports a GPG key only when the secret keyring does not already have one, and
reads each 1Password item once. When gh is authenticated, the GitHub token
comes from `gh auth token` instead of 1Password. `purr check` does not call
1Password.
EOF
  }

  while [ "$#" -gt 0 ]; do
    case $1 in
      -v | --verbose)
        verbose=true
        PURR_VERBOSE=true
        shift
        ;;
      -h | --help)
        print_help
        return 0
        ;;
      check | lock | setup)
        command=$1
        shift
        ;;
      *)
        if [ -z "$command" ]; then
          command=$1
        else
          printf 'Unknown argument: %s\n' "$1" >&2
          print_help
          return 1
        fi
        shift
        ;;
    esac
  done

  case "$command" in
    check)
      printf 'purr check\n'
      purr_check "$verbose"
      ;;
    lock)
      purr_lock "$verbose"
      ;;
    setup | "")
      purr_banner "ᓚᘏᗢ purr setup"
      purr_setup "$verbose"
      ;;
    *)
      printf 'Unknown command: %s\n' "$command" >&2
      print_help
      return 1
      ;;
  esac
}
