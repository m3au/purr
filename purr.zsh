#!/usr/bin/env zsh
# purr - ZSH plugin for seamless key management with 1Password, SSH, and GPG
# shellcheck disable=SC1090

# Configuration: 1Password vault and item names
# These can be overridden via environment variables
PURR_VAULT_NAME="${PURR_VAULT_NAME:-purr}"
PURR_GPG_ITEM="${PURR_GPG_ITEM:-gpg}"
PURR_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"

# Configuration: SSH agent socket and GPG cache TTL
# These can be overridden via environment variables
PURR_SSH_AUTH_SOCK="${PURR_SSH_AUTH_SOCK:-$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock}"
PURR_GPG_CACHE_TTL="${PURR_GPG_CACHE_TTL:-34560000}"

# Load configuration file if it exists (~/.purrrc)
# This allows users to override default settings
if [ -f "$HOME/.purrrc" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.purrrc"
fi

# Obfuscate sensitive key data for safe display
# Arguments:
#   $1: Input string to obfuscate
# Returns: Obfuscated string (shows first 4 and last 4 characters)
# Example: obfuscate_key "ghp_abcdefghijklmnopqrstuvwxyz1234567890"
obfuscate_key() {
  local input=$1
  local visible_chars=4
  local str_length=${#input}
  local middle_length
  local stars

  if [ "$str_length" -le $((visible_chars * 2)) ]; then
    echo "$input"
  else
    local start=${input:0:$visible_chars}
    local end=${input: -$visible_chars}
    middle_length=$((str_length - visible_chars * 2))
    stars=$(printf '%*s' "$middle_length" | tr ' ' '*')
    echo "${start}${stars}${end}"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script should be sourced, not executed directly."
  exit 1
fi

# Load SSH keys from 1Password SSH agent
# Connects to the 1Password SSH agent socket and verifies keys are available
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: 0 on success, 1 on failure
# Environment: Sets SSH_AUTH_SOCK to 1Password SSH agent socket
# Example: load_ssh_key true
load_ssh_key() {
  local verbose=$1
  $verbose && echo "Loading SSH key..."

  # Set the SSH_AUTH_SOCK to the 1Password SSH agent socket
  export SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK"

  if [ -S "$SSH_AUTH_SOCK" ]; then
    $verbose && echo "Connected to 1Password SSH agent."

    # Check if any identities are available
    if ssh-add -l 2>&1 | grep -q "The agent has no identities."; then
      $verbose && echo "No identities available in the 1Password SSH agent."
      return 1
    else
      $verbose && echo "SSH keys are available in the 1Password SSH agent."
      return 0
    fi
  else
    $verbose && echo "Failed to connect to 1Password SSH agent. Is 1Password running?"
    return 1
  fi
}

# Unload SSH keys by disconnecting from SSH agent
# Clears SSH_AUTH_SOCK and SSH_AGENT_PID environment variables
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: Always returns 0
# Environment: Unsets SSH_AUTH_SOCK and SSH_AGENT_PID
# Example: unload_ssh_key true
unload_ssh_key() {
  local verbose=$1
  if $verbose; then
    echo "Disconnecting from 1Password SSH agent..."
    echo "SSH_AUTH_SOCK was: $SSH_AUTH_SOCK"
  fi
  unset SSH_AUTH_SOCK
  unset SSH_AGENT_PID
  if $verbose; then
    echo "SSH agent environment variables unset."
    echo "SSH_AUTH_SOCK is now: $SSH_AUTH_SOCK"
  fi
}

# Load GPG key from 1Password and configure Git signing
# Retrieves GPG key data from 1Password, imports keys, configures GPG agent,
# and sets up Git commit signing
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: 0 on success, 1 on failure
# Environment:
#   - Uses PURR_VAULT_NAME and PURR_GPG_ITEM for 1Password lookup
#   - Creates temporary files for key import (cleaned up automatically)
#   - Configures ~/.gnupg/gpg-agent.conf with cache TTL
#   - Sets Git global config for GPG signing
# Example: load_gpg_key true
load_gpg_key() {
  local verbose=$1
  $verbose && echo "Starting GPG key loading process..."
  $verbose && echo "Retrieving GPG key information from 1Password..."

  local gpg_key_id
  local password
  gpg_key_id=$(op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT_NAME" --field key_id)
  password=$(op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT_NAME" --field password --reveal)

  if [ -z "$gpg_key_id" ] || [ -z "$password" ]; then
    $verbose && echo "Failed to retrieve key ID or password from 1Password."
    return 1
  fi

  $verbose && echo "Retrieving public and private keys..."
  local public_key
  local private_key
  public_key=$(op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT_NAME" --field public_key)
  private_key=$(op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT_NAME" --field private_key)

  if [ -z "$public_key" ] || [ -z "$private_key" ]; then
    $verbose && echo "Failed to retrieve public or private key from 1Password."
    return 1
  fi

  $verbose && echo "Creating temporary files for key import..."
  local temp_public_key
  local temp_private_key
  temp_public_key=$(mktemp)
  temp_private_key=$(mktemp)

  # Cleanup function for temporary files
  cleanup_temp_keys() {
    rm -f "$temp_public_key" "$temp_private_key" 2>/dev/null
  }
  trap cleanup_temp_keys EXIT INT TERM

  $verbose && echo "Writing keys to temporary files..."
  echo "$public_key" | sed 's/^"//; s/"$//; s/\\n/\n/g' >"$temp_public_key"
  echo "$private_key" | sed 's/^"//; s/"$//; s/\\n/\n/g' >"$temp_private_key"

  $verbose && echo "Verifying key contents..."
  $verbose && echo "Public key (first 50 characters):"
  $verbose && head -c 50 "$temp_public_key"
  $verbose && echo
  $verbose && echo "Private key (first 50 characters):"
  $verbose && head -c 50 "$temp_private_key"
  $verbose && echo

  $verbose && echo "Importing public GPG key..."
  import_output=$(gpg --batch --yes --import "$temp_public_key" 2>&1)

  $verbose && echo "Importing private GPG key..."
  import_output=$(gpg --batch --yes --passphrase "$password" --import "$temp_private_key" 2>&1)

  $verbose && echo "Cleaning up temporary files..."
  rm -f "$temp_public_key" "$temp_private_key"
  trap - EXIT INT TERM

  $verbose && echo "Configuring GPG agent cache..."
  mkdir -p ~/.gnupg
  echo "default-cache-ttl $PURR_GPG_CACHE_TTL" >~/.gnupg/gpg-agent.conf
  echo "max-cache-ttl $PURR_GPG_CACHE_TTL" >>~/.gnupg/gpg-agent.conf

  $verbose && echo "Restarting GPG agent..."
  gpgconf --kill gpg-agent
  gpg-agent --daemon

  $verbose && echo "Testing GPG key functionality..."

  $verbose && echo "Caching GPG passphrase in the agent..."
  local agent_response
  agent_response=$(echo "RELOADAGENT" | gpg-connect-agent 2>&1)
  if [[ "$agent_response" != "OK" ]]; then
    $verbose && echo "GPG agent response: $agent_response"
  fi

  $verbose && echo "Creating temporary file for passphrase test..."
  local passphrase_file
  passphrase_file=$(mktemp)
  echo -n "$password" >"$passphrase_file"

  $verbose && echo "Testing signing capability..."
  local temp_file
  temp_file=$(mktemp)
  echo "test" >"$temp_file"

  # Cleanup function for test files
  cleanup_test_files() {
    rm -f "$temp_file" "$temp_file.gpg" "${temp_file}.error" "$passphrase_file" 2>/dev/null
  }
  trap cleanup_test_files EXIT INT TERM

  if gpg --batch --yes --passphrase-file "$passphrase_file" --pinentry-mode loopback -u "$gpg_key_id" -s "$temp_file" 2>"${temp_file}.error"; then
    $verbose && echo "Successfully signed test file. Passphrase cached."
    rm -f "$temp_file" "$temp_file.gpg" "${temp_file}.error" "$passphrase_file"
    trap - EXIT INT TERM
  else
    $verbose && echo "Failed to sign test file. Error output:"
    cat "${temp_file}.error"
    rm -f "$temp_file" "${temp_file}.error" "$passphrase_file"
    trap - EXIT INT TERM
    return 1
  fi

  $verbose && echo "Configuring Git GPG signing..."
  git config --global user.signingkey "$gpg_key_id"
  git config --global commit.gpgsign true
  git config --global gpg.program "$(command -v gpg)"

  $verbose && echo "Verifying Git GPG configuration..."
  $verbose && echo "Git GPG signing configured with key: $gpg_key_id"
  $verbose && echo "GPG program path: $(command -v gpg)"
  $verbose && echo "Git config:"
  $verbose && git config --global --list | grep gpg

  $verbose && echo "Performing final GPG signing test..."
  if echo "test" | gpg --clearsign >/dev/null 2>&1; then
    $verbose && echo "GPG signing test successful."
  else
    $verbose && echo "GPG signing test failed."
    return 1
  fi

  $verbose && echo "GPG key loaded successfully and Git configured for signing."
  return 0
}

# Unload GPG keys by removing from keyring and clearing agent cache
# Deletes secret keys from GPG keyring and stops GPG agent
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: Always returns 0
# Example: unload_gpg_key true
unload_gpg_key() {
  local verbose=$1
  local fingerprint
  if $verbose; then
    echo "Removing GPG key..."
  fi
  fingerprint=$(gpg --list-secret-keys --with-colons --fingerprint | awk -F: '$1 == "fpr" {print $10; exit}')
  if [ -n "$fingerprint" ]; then
    if gpg --batch --yes --delete-secret-keys "$fingerprint" >/dev/null 2>&1; then
      $verbose && echo "GPG key removed from keyring."
    else
      $verbose && echo "Failed to remove GPG key."
    fi
  else
    $verbose && echo "No GPG key found to remove."
  fi

  if $verbose; then
    echo "Clearing GPG agent cache..."
  fi
  gpg-connect-agent reloadagent /bye >/dev/null 2>&1
  gpg-connect-agent killagent /bye >/dev/null 2>&1
  $verbose && echo "GPG agent cache cleared and agent stopped."
}

# Check status of SSH and GPG keys
# Displays comprehensive status information about SSH keys, GPG keys,
# Git signing configuration, and GitHub token status
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: Always returns 0
# Example: check_keys false
check_keys() {
  local verbose=$1
  $verbose && echo "Starting key status check..."

  echo "Checking for SSH keys:"
  if [ -d ~/.ssh ]; then
    local ssh_keys
    ssh_keys=$(find ~/.ssh -maxdepth 1 -name "*.pub" 2>/dev/null | sed 's/\.pub$//')
    if [ -n "$ssh_keys" ]; then
      echo "SSH keys found:"
      echo "$ssh_keys" | sed 's/^/  /'
    else
      echo "No SSH public keys found in ~/.ssh/"
    fi
  else
    echo "No ~/.ssh directory found"
  fi

  echo -e "\nChecking SSH agent connection:"
  if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Not connected to any SSH agent."
  else
    echo "Connected to SSH agent at $SSH_AUTH_SOCK"
    echo "Loaded keys:"
    ssh-add -l 2>/dev/null || echo "No keys loaded or unable to communicate with agent."
  fi

  echo -e "\nChecking for GPG keys:"
  if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "sec"; then
    echo "GPG keys found:"
    gpg --list-secret-keys --keyid-format LONG | grep -E "^sec|^uid" | sed 's/^sec.*\/\([^ ]*\).*/  Key ID: \1/; s/^uid.*] /  Name: /'
  else
    echo "No GPG keys found on this system."
  fi

  echo -e "\nChecking loaded GPG keys:"
  if gpg-agent --quiet 2>/dev/null; then
    local loaded_keys
    loaded_keys=$(gpg --list-secret-keys --with-keygrip 2>/dev/null | awk '/Keygrip/ {print "  " $3}')
    if [ -n "$loaded_keys" ]; then
      echo "GPG agent is running. Loaded keys:"
      echo "$loaded_keys"
    else
      echo "GPG agent is running, but no keys are loaded."
    fi
  else
    echo "GPG agent is not running or no keys are loaded."
  fi

  echo -e "\nChecking Git GPG signing status:"
  local signing_key=$(git config --global user.signingkey)
  local commit_sign=$(git config --global commit.gpgsign)

  if [ -n "$signing_key" ] && [ "$commit_sign" = "true" ]; then
    echo "Git GPG signing is enabled."
    echo "  Signing key: $signing_key"
  else
    echo "Git GPG signing is disabled."
    [ -n "$signing_key" ] && echo "  Signing key is set ($signing_key) but commit signing is not enabled."
    [ "$commit_sign" = "true" ] && echo "  Commit signing is enabled but no signing key is set."
  fi

  if [ -n "$signing_key" ]; then
    echo -e "\nChecking if the configured GPG key is available:"
    if gpg --list-secret-keys "$signing_key" >/dev/null 2>&1; then
      echo "  GPG key $signing_key is available in the keyring."
    else
      echo "  WARNING: GPG key $signing_key is not available in the keyring."
    fi
  fi

  echo -e "\nChecking if GPG passphrase is cached in the agent:"
  $verbose && echo "Retrieving Git signing key..."
  local signing_key=$(git config --global user.signingkey)
  if [ -n "$signing_key" ]; then
    $verbose && echo "Looking up keygrip for signing key: $signing_key..."
    local keygrip=$(gpg --with-keygrip --list-secret-keys "$signing_key" 2>/dev/null | awk '/Keygrip/ {print $3; exit}')
    if [ -n "$keygrip" ]; then
      $verbose && echo "Checking if keygrip $keygrip is cached in GPG agent..."
      if gpg-connect-agent "keyinfo --list" /bye | grep -q "$keygrip"; then
        echo "  GPG passphrase is cached in the agent."
      else
        echo "  GPG passphrase is not cached in the agent."
      fi
    else
      echo "  Could not determine keygrip for the GPG key."
    fi
  else
    echo "  No GPG signing key configured in Git."
  fi

  echo -e "\nChecking GitHub token status:"
  if [ -n "$GITHUB_TOKEN" ]; then
    echo "  GITHUB_TOKEN environment variable: Set ($(obfuscate_key "$GITHUB_TOKEN"))"
  else
    echo "  GITHUB_TOKEN environment variable: Not set"
  fi

  if [ -f ~/.cursor/env ]; then
    echo "  ~/.cursor/env file: Exists"
    if $verbose; then
      echo "  File contents preview:"
      head -n 2 ~/.cursor/env | sed 's/.*/    &/'
    fi
  else
    echo "  ~/.cursor/env file: Not found"
  fi
}

# Enable Git GPG commit signing
# Configures Git global settings for GPG commit signing using key from 1Password
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: 0 on success, 1 on failure
# Environment:
#   - Uses PURR_VAULT_NAME and PURR_GPG_ITEM for 1Password lookup
#   - Sets git config --global user.signingkey
#   - Sets git config --global commit.gpgsign true
#   - Sets git config --global gpg.program
# Example: enable_git_signing true
enable_git_signing() {
  local verbose=$1
  $verbose && echo "Starting Git GPG signing configuration..."
  $verbose && echo "Retrieving GPG key ID from 1Password..."

  local gpg_key_id
  gpg_key_id=$(op item get "$PURR_GPG_ITEM" --vault "$PURR_VAULT_NAME" --field key_id)

  if [ -z "$gpg_key_id" ]; then
    $verbose && echo "No GPG key ID found in 1Password. Make sure a GPG key is loaded."
    return 1
  fi

  git config --global user.signingkey "$gpg_key_id"
  git config --global commit.gpgsign true
  git config --global gpg.program "$(command -v gpg)"

  $verbose && echo "Git GPG signing enabled with key: $gpg_key_id"
  $verbose && echo "GPG program path: $(command -v gpg)"
  $verbose && echo "Git config:"
  $verbose && git config --global --list | grep gpg

  return 0
}

# Disable Git GPG commit signing
# Removes Git global GPG signing configuration
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: Always returns 0
# Environment: Unsets git config --global user.signingkey and commit.gpgsign
# Example: disable_git_signing true
disable_git_signing() {
  local verbose=$1
  $verbose && echo "Disabling Git GPG signing..."

  git config --global --unset user.signingkey
  git config --global --unset commit.gpgsign

  $verbose && echo "Git GPG signing disabled."
  return 0
}

# Check for existing key configuration
# Detects if SSH agent, GPG keys, or Git signing are already configured
# Arguments: None
# Returns: Always returns 0
# Output: Prints status details about existing configuration
# Example: check_existing_setup
check_existing_setup() {
  local has_existing=false
  local details=""

  echo "Checking existing configuration..."

  if [ -n "$SSH_AUTH_SOCK" ]; then
    has_existing=true
    details="${details}🔑 SSH agent is connected\n"
    if ssh-add -l 2>/dev/null | grep -q "The agent has no identities."; then
      details="${details}    ✗ No keys loaded\n"
    else
      details="${details}    ✓ Keys loaded\n"
    fi
  fi

  if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "sec"; then
    has_existing=true
    details="${details}🔐 GPG keys are present\n"
    local key_count=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -c "^sec")
    details="${details}    ✓ ${key_count} key(s) loaded\n"
  fi

  local signing_key=$(git config --global user.signingkey)
  local commit_sign=$(git config --global commit.gpgsign)
  if [ -n "$signing_key" ] || [ "$commit_sign" = "true" ]; then
    has_existing=true
    details="${details}📝 Git signing is configured\n"
    [ -n "$signing_key" ] && details="${details}    ✓ Signing key is set\n"
    [ "$commit_sign" = "true" ] && details="${details}    ✓ Commit signing is enabled\n"
  fi

  return 0
}

# Check 1Password status and authenticate if needed
# Verifies 1Password desktop app is running, launches if needed, and authenticates CLI
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: 0 on success, 1 on failure
# Example: check_1password true
check_1password() {
  local verbose=$1
  $verbose && echo "Checking 1Password status..."

  # Check if 1Password is running
  if ! pgrep -q "1Password"; then
    echo "1Password is not running. Attempting to launch..."
    open -a "1Password"

    # Wait for up to 10 seconds for 1Password to launch
    local attempts=0
    while ! pgrep -q "1Password" && [ $attempts -lt 10 ]; do
      sleep 1
      ((attempts++))
    done

    if ! pgrep -q "1Password"; then
      echo "❌ Failed to launch 1Password. Please start it manually and try again."
      return 1
    fi

    echo "✨ 1Password launched. Please sign in if needed."
    echo "Press any key once you've signed in..."
    read -k 1 -s
  fi

  # Test connection to 1Password CLI
  if ! op account get >/dev/null 2>&1; then
    echo "🔐 Please authenticate with 1Password CLI..."
    if ! eval $(op signin); then
      echo "❌ Failed to authenticate with 1Password CLI."
      echo "Please ensure:"
      echo "  1. 1Password desktop app is running and you're signed in"
      echo "  2. 1Password CLI integration is enabled in preferences"
      echo "  3. You have the latest version of 1Password"
      return 1
    fi
  fi

  $verbose && echo "✅ 1Password is running and authenticated"
  return 0
}

# Main purr command function
# Provides key management commands: load keys, check status, or lock/unload keys
# Commands:
#   (none) - Load SSH and GPG keys, configure Git signing and GitHub credentials
#   check  - Display status of SSH and GPG keys
#   lock   - Unload all keys and lock 1Password
# Options:
#   -v    - Verbose mode (enable verbose output)
#   -h    - Show help message
# Returns: 0 on success, 1 on failure
# Example: purr          # Load keys
# Example: purr check    # Check status
# Example: purr lock     # Unload keys
# Example: purr -v       # Load keys with verbose output
purr() {
  local verbose=false
  local success=true
  local command=""

  echo "ᓚᘏᗢ purr initializing..." | lolcat -a

  print_help() {
    echo "Usage: purr [command] [-v]"
    echo
    echo "Commands:"
    echo "  (none)    Load SSH and GPG keys"
    echo "  check     Check status of SSH and GPG keys"
    echo "  lock      Unload SSH and GPG keys and lock 1Password"
    echo "  -h        Show this help message"
    echo
    echo "Options:"
    echo "  -v        Verbose mode"
  }

  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -v)
      verbose=true
      shift
      ;;
    -h)
      print_help
      return 0
      ;;
    check | lock)
      command=$1
      shift
      ;;
    *)
      if [ -z "$command" ]; then
        command=$1
      else
        echo "Unknown argument: $1"
        print_help
        return 1
      fi
      shift
      ;;
    esac
  done

  case "$command" in
  check)
    check_keys $verbose
    ;;
  lock)
    if $verbose; then
      op signout --all
      unload_ssh_key true
      unload_gpg_key true
      disable_git_signing true
      unset GITHUB_TOKEN
      rm -f ~/.cursor/mcp.json
      echo "System locked" | lolcat -a
    else
      op signout --all >/dev/null 2>&1
      unload_ssh_key false >/dev/null 2>&1
      unload_gpg_key false >/dev/null 2>&1
      disable_git_signing false >/dev/null 2>&1
      unset GITHUB_TOKEN
      rm -f ~/.cursor/mcp.json >/dev/null 2>&1
      echo "System locked" | lolcat -a
    fi
    echo "ᓚᘏᗢ hiss" | lolcat -a
    ;;
  "")
    if ! check_1password $verbose; then
      return 1
    fi

    if ! load_ssh_key $verbose; then
      echo "Failed: SSH key"
      return 1
    fi

    if ! load_gpg_key $verbose; then
      echo "Failed: GPG key"
      return 1
    fi

    if ! enable_git_signing $verbose; then
      echo "Failed: Git signing"
      return 1
    fi

    # Setup GitHub credentials (optional, won't fail if not available)
    setup_github_credentials $verbose

    echo -e "\nCredentials loaded:" | lolcat -a
    local github_user
    github_user=$(git config --global user.name)
    echo "GitHub: $github_user" | lolcat -a
    if [ -n "$GITHUB_TOKEN" ]; then
      echo "GitHub Token: $(obfuscate_key "$GITHUB_TOKEN")" | lolcat -a
    fi
    echo "Git signing: Enabled" | lolcat -a
    local gpg_key
    gpg_key=$(git config --global user.signingkey)
    echo "GPG: $(obfuscate_key "$gpg_key")" | lolcat -a
    echo "SSH: Connected" | lolcat -a
    echo "ᓚᘏᗢ purr" | lolcat -a
    return 0
    ;;
  *)
    echo "Unknown command: $command"
    print_help
    return 1
    ;;
  esac
}

# Check GPG key status and display details
# Verifies GPG key exists and displays obfuscated key details
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
#   $2: GPG key ID to check
# Returns: Always returns 0
# Output: Displays obfuscated key information
# Example: check_gpg_key true "ABC123DEF456"
check_gpg_key() {
  local verbose=$1
  local gpg_key_id=$2

  $verbose && echo "Starting GPG key status check..."
  $verbose && echo "Checking public key presence..."

  if gpg --list-keys "$gpg_key_id" >/dev/null 2>&1; then
    $verbose && echo "Public key found."
  else
    $verbose && echo "Public key not found."
  fi

  if gpg --list-secret-keys "$gpg_key_id" >/dev/null 2>&1; then
    $verbose && echo "Secret key found."
  else
    $verbose && echo "Secret key not found."
  fi

  $verbose && echo "Key details:"
  gpg --list-keys --with-fingerprint "$gpg_key_id" | while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*[A-F0-9]{4}[[:space:]] ]]; then

      fingerprint=$(echo "$line" | tr -d '[:space:]')
      echo "      $(obfuscate_key "$fingerprint")"
    elif [[ $line =~ [A-F0-9]{16,} ]]; then

      echo "$line" | sed -E "s/([A-F0-9]{16,})/$(obfuscate_key '\1')/g"
    elif [[ $line =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then

      echo "$line" | sed -E "s/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$(obfuscate_key '\1')/g"
    else
      echo "$line"
    fi
  done

  $verbose && echo "Secret key details:"
  gpg --list-secret-keys --with-fingerprint "$gpg_key_id" | while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*[A-F0-9]{4}[[:space:]] ]]; then

      fingerprint=$(echo "$line" | tr -d '[:space:]')
      echo "      $(obfuscate_key "$fingerprint")"
    elif [[ $line =~ [A-F0-9]{16,} ]]; then

      echo "$line" | sed -E "s/([A-F0-9]{16,})/$(obfuscate_key '\1')/g"
    elif [[ $line =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then

      echo "$line" | sed -E "s/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/$(obfuscate_key '\1')/g"
    else
      echo "$line"
    fi
  done
}

# Reimport GPG secret key (helper function)
# Exports and reimports a GPG secret key, useful for troubleshooting
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
#   $2: GPG key ID to reimport
#   $3: Key passphrase
# Returns: 0 on success, 1 on failure
# Example: reimport_secret_key true "ABC123DEF456" "passphrase"
reimport_secret_key() {
  local verbose=$1
  local gpg_key_id=$2
  local password=$3

  $verbose && echo "Starting secret key reimport process..."
  $verbose && echo "Attempting to export existing secret key..."

  local export_output
  export_output=$(gpg --batch --yes --passphrase "$password" --export-secret-keys "$gpg_key_id" 2>&1)
  if [ $? -ne 0 ]; then
    $verbose && echo "Failed to export secret key: $export_output"
    return 1
  fi

  local import_output
  import_output=$(echo "$export_output" | gpg --batch --yes --passphrase "$password" --import 2>&1)
  $verbose && echo "Reimport output: $import_output"

  if echo "$import_output" | grep -q "secret key imported"; then
    $verbose && echo "Secret key successfully reimported."
    return 0
  else
    $verbose && echo "Failed to reimport secret key."
    return 1
  fi
}

# Setup GitHub credentials from 1Password
# Retrieves GitHub username, email, and personal access token from 1Password,
# configures Git user settings, stores credentials in macOS keychain, and exports
# GITHUB_TOKEN environment variable. Also updates Cursor MCP configuration.
# Arguments:
#   $1: Verbose flag (true/false) - controls output verbosity
# Returns: 0 on success, 1 on failure (returns 0 if GitHub item doesn't exist - optional)
# Environment:
#   - Uses PURR_VAULT_NAME and PURR_GITHUB_ITEM for 1Password lookup
#   - Sets git config --global user.name and user.email
#   - Exports GITHUB_TOKEN environment variable
#   - Creates/updates ~/.cursor/mcp.json with GitHub token
# Example: setup_github_credentials true
setup_github_credentials() {
  local verbose=$1
  $verbose && echo "Setting up GitHub credentials..."

  # Check if 1Password is accessible first
  if ! op account get >/dev/null 2>&1; then
    echo "✗ Not authenticated with 1Password. Please sign in first."
    return 0  # GitHub is optional
  fi

  # First, let's verify the item exists
  $verbose && echo "Checking GitHub item in 1Password..."
  if ! op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT_NAME" >/dev/null 2>&1; then
    
    return 0  # GitHub is optional
  fi

  # Retrieve credentials with error checking
  local github_user
  local github_email
  local github_pat

  $verbose && echo "Retrieving GitHub credentials..."
  # Try common field names for username
  for field in "username" "user" "login"; do
    if github_user=$(op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT_NAME" --field "$field" 2>/dev/null); then
      $verbose && echo "✓ Username retrieved"
      break
    fi
  done

  # Try common field names for email
  for field in "email" "mail" "email address"; do
    if github_email=$(op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT_NAME" --field "$field" 2>/dev/null); then
      $verbose && echo "✓ Email retrieved"
      break
    fi
  done

  # Try common field names for PAT
  for field in "pat" "token" "access token" "personal access token" "password"; do
    if github_pat=$(op item get "$PURR_GITHUB_ITEM" --vault "$PURR_VAULT_NAME" --field "$field" --reveal 2>/dev/null); then
      $verbose && echo "✓ Token retrieved"
      break
    fi
  done

  if [ -z "$github_user" ] || [ -z "$github_email" ] || [ -z "$github_pat" ]; then
    echo "✗ One or more GitHub credentials are missing"
    return 1
  fi

  $verbose && echo "Setting Git username..."
  if ! git config --global user.name "$github_user"; then
    echo "✗ Failed to set Git username"
    return 1
  fi
  $verbose && echo "✓ Git username set"

  $verbose && echo "Setting Git email..."
  if ! git config --global user.email "$github_email"; then
    echo "✗ Failed to set Git email"
    return 1
  fi
  $verbose && echo "✓ Git email set"

  $verbose && echo "Storing GitHub credentials in keychain..."
  if ! printf "protocol=https\nhost=github.com\nusername=%s\npassword=%s\n" "$github_user" "$github_pat" | git credential-osxkeychain store; then
    echo "✗ Failed to store GitHub credentials in keychain"
    return 1
  fi
  $verbose && echo "✓ GitHub credentials stored in keychain"

  $verbose && echo "Exporting GITHUB_TOKEN environment variable..."
  export GITHUB_TOKEN="$github_pat"
  $verbose && echo "✓ GITHUB_TOKEN exported"

  # Create/update .cursor/mcp.json with the actual token value
  $verbose && echo "Updating ~/.cursor/mcp.json with GitHub token..."

  # Escape special characters in the token for JSON
  local escaped_token
  escaped_token=$(printf '%s' "$github_pat" | sed 's/\\/\\\\/g; s/"/\\"/g')

  # Create mcp.json with the actual token value
  cat > ~/.cursor/mcp.json << EOF
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$escaped_token"
      }
    }
  }
}
EOF
  $verbose && echo "✓ Updated ~/.cursor/mcp.json with GitHub token"

  $verbose && echo "✓ GitHub credentials configured successfully"
  return 0
}
