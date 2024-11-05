
colorize() {
  local message="$1"
  if command -v lolcat >/dev/null 2>&1; then
    echo "$message" | lolcat ${2:--a}
  else
    echo "$message"
  fi
}

obfuscate_key() {
  local input=$1
  local visible_chars=4
  local str_length=${#input}

  if [ $str_length -le $(($visible_chars * 2)) ]; then
    echo "$input"
  else
    local start=${input:0:$visible_chars}
    local end=${input: -$visible_chars}
    local middle_length=$(($str_length - $visible_chars * 2))
    local stars=$(printf '%*s' $middle_length | tr ' ' '*')
    echo "${start}${stars}${end}"
  fi
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script should be sourced, not executed directly."
  exit 1
else
  colorize "ᓚᘏᗢ purr source loaded"
fi


load_ssh_key() {
  local verbose=$1
  $verbose && echo "➜ Starting SSH key loading process..."
  $verbose && echo "➜ Setting SSH_AUTH_SOCK to 1Password agent socket..."

  export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

  if [ -S "$SSH_AUTH_SOCK" ]; then
    $verbose && echo "➜ Checking for available identities in 1Password SSH agent..."

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


load_gpg_key() {
  local verbose=$1
  $verbose && echo "➜ Starting GPG key loading process..."
  $verbose && echo "➜ Retrieving GPG key information from 1Password..."

  local gpg_key_id=$(op item get "m3au gpg" --vault "Purr" --field key_id)
  local password=$(op item get "m3au gpg" --vault "Purr" --field password --reveal)

  if [ -z "$gpg_key_id" ] || [ -z "$password" ]; then
    $verbose && echo "Failed to retrieve key ID or password from 1Password."
    return 1
  fi

  $verbose && echo "➜ Retrieving public and private keys..."
  local public_key=$(op item get "m3au gpg" --vault "Purr" --field public_key)
  local private_key=$(op item get "m3au gpg" --vault "Purr" --field private_key)

  if [ -z "$public_key" ] || [ -z "$private_key" ]; then
    $verbose && echo "Failed to retrieve public or private key from 1Password."
    return 1
  fi

  $verbose && echo "➜ Creating temporary files for key import..."
  local temp_public_key=$(mktemp)
  local temp_private_key=$(mktemp)

  $verbose && echo "➜ Writing keys to temporary files..."
  echo "$public_key" | sed 's/^"//; s/"$//; s/\\n/\n/g' >"$temp_public_key"
  echo "$private_key" | sed 's/^"//; s/"$//; s/\\n/\n/g' >"$temp_private_key"

  $verbose && echo "➜ Verifying key contents..."
  $verbose && echo "Public key (first 50 characters):"
  $verbose && head -c 50 "$temp_public_key"
  $verbose && echo
  $verbose && echo "Private key (first 50 characters):"
  $verbose && head -c 50 "$temp_private_key"
  $verbose && echo

  $verbose && echo "➜ Importing public GPG key..."
  import_output=$(gpg --batch --yes --import "$temp_public_key" 2>&1)

  $verbose && echo "➜ Importing private GPG key..."
  import_output=$(gpg --batch --yes --passphrase "$password" --import "$temp_private_key" 2>&1)

  $verbose && echo "➜ Cleaning up temporary files..."
  rm -f "$temp_public_key" "$temp_private_key"

  $verbose && echo "➜ Configuring GPG agent cache..."
  mkdir -p ~/.gnupg
  echo "default-cache-ttl 34560000" >~/.gnupg/gpg-agent.conf
  echo "max-cache-ttl 34560000" >>~/.gnupg/gpg-agent.conf

  $verbose && echo "➜ Restarting GPG agent..."
  gpgconf --kill gpg-agent
  gpg-agent --daemon

  $verbose && echo "➜ Testing GPG key functionality..."

  $verbose && echo "➜ Caching GPG passphrase in the agent..."
  local agent_response=$(echo "RELOADAGENT" | gpg-connect-agent 2>&1)
  if [[ "$agent_response" != "OK" ]]; then
    $verbose && echo "GPG agent response: $agent_response"
  fi


  $verbose && echo "➜ Creating temporary file for passphrase test..."
  passphrase_file=$(mktemp)
  echo -n "$password" >"$passphrase_file"


  $verbose && echo "➜ Testing signing capability..."
  temp_file=$(mktemp)
  echo "test" >"$temp_file"
  if gpg --batch --yes --passphrase-file "$passphrase_file" --pinentry-mode loopback -u "$gpg_key_id" -s "$temp_file" 2>"${temp_file}.error"; then
    $verbose && echo "Successfully signed test file. Passphrase cached."
    rm -f "$temp_file" "$temp_file.gpg" "${temp_file}.error" "$passphrase_file"
  else
    $verbose && echo "Failed to sign test file. Error output:"
    cat "${temp_file}.error"
    rm -f "$temp_file" "${temp_file}.error" "$passphrase_file"
    return 1
  fi

  $verbose && echo "➜ Configuring Git GPG signing..."
  git config --global user.signingkey "$gpg_key_id"
  git config --global commit.gpgsign true
  git config --global gpg.program $(which gpg)

  $verbose && echo "➜ Verifying Git GPG configuration..."
  $verbose && echo "Git GPG signing configured with key: $gpg_key_id"
  $verbose && echo "GPG program path: $(which gpg)"
  $verbose && echo "Git config:"
  $verbose && git config --global --list | grep gpg


  $verbose && echo "➜ Performing final GPG signing test..."
  if echo "test" | gpg --clearsign >/dev/null 2>&1; then
    $verbose && echo "GPG signing test successful."
  else
    $verbose && echo "GPG signing test failed."
    return 1
  fi

  $verbose && echo "GPG key loaded successfully and Git configured for signing."
  return 0
}

unload_gpg_key() {
  local verbose=$1
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


check_keys() {
  local verbose=$1
  $verbose && echo "➜ Starting key status check..."

  echo "➜ Checking for SSH keys:"
  if [ -d ~/.ssh ]; then
    local ssh_keys=$(ls -1 ~/.ssh/*.pub 2>/dev/null | sed 's/\.pub$//')
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
    local loaded_keys=$(gpg --list-secret-keys --with-keygrip 2>/dev/null | awk '/Keygrip/ {print "  " $3}')
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
  $verbose && echo "➜ Retrieving Git signing key..."
  local signing_key=$(git config --global user.signingkey)
  if [ -n "$signing_key" ]; then
    $verbose && echo "➜ Looking up keygrip for signing key: $signing_key..."
    local keygrip=$(gpg --with-keygrip --list-secret-keys "$signing_key" 2>/dev/null | awk '/Keygrip/ {print $3; exit}')
    if [ -n "$keygrip" ]; then
      $verbose && echo "➜ Checking if keygrip $keygrip is cached in GPG agent..."
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
}


enable_git_signing() {
  local verbose=$1
  $verbose && echo "➜ Starting Git GPG signing configuration..."
  $verbose && echo "➜ Retrieving GPG key ID from 1Password..."

  local gpg_key_id=$(op item get "m3au gpg" --vault "Purr" --field key_id)

  if [ -z "$gpg_key_id" ]; then
    $verbose && echo "No GPG key ID found in 1Password. Make sure a GPG key is loaded."
    return 1
  fi


  git config --global user.signingkey $gpg_key_id
  git config --global commit.gpgsign true
  git config --global gpg.program $(which gpg)

  $verbose && echo "Git GPG signing enabled with key: $gpg_key_id"
  $verbose && echo "GPG program path: $(which gpg)"
  $verbose && echo "Git config:"
  $verbose && git config --global --list | grep gpg

  return 0
}


disable_git_signing() {
  local verbose=$1
  $verbose && echo "Disabling Git GPG signing..."


  git config --global --unset user.signingkey
  git config --global --unset commit.gpgsign

  $verbose && echo "Git GPG signing disabled."
  return 0
}


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

  if $has_existing; then
    colorize "✨ Existing configuration found"
    echo -e "\nCurrent setup:"
    echo -e "${details}"
    echo -n "Override existing configuration? [y/N] "
    read -k 1 REPLY
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
    return $?
  fi

  return 0
}


purr() {
  local verbose=false
  local success=true
  local command=""


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
    echo "🔍 Checking key status..."
    check_keys $verbose
    ;;
  lock)
    if $verbose; then
      colorize "🔒 Locking system..."
      echo "➜ Signing out of 1Password..."
      op signout --all
      echo "➜ Unloading SSH key..."
      unload_ssh_key true
      echo "➜ Unloading GPG key..."
      unload_gpg_key true
      echo "➜ Disabling Git signing..."
      disable_git_signing true
      colorize "✓ System locked"
    else
      op signout --all >/dev/null 2>&1
      unload_ssh_key false >/dev/null 2>&1
      unload_gpg_key false >/dev/null 2>&1
      disable_git_signing false >/dev/null 2>&1
    fi
    colorize "ᓚᘏᗢ hiss"
    ;;
  "")
    colorize "Starting key management..."

    if ! check_existing_setup; then
      colorize "✗ Setup cancelled"
      return 1
    fi

    local steps_total=4
    local current_step=1

    if ! pgrep -q "1Password"; then
      echo "🔑 Launching 1Password..."
      open -a "1Password"
      echo "Please sign in to 1Password and press any key to continue."
      read -k 1 -s
    fi

    if ! op account get >/dev/null 2>&1; then
      echo "🔒 Authenticating with 1Password..."
      eval $(op signin)
    fi

    echo "[$current_step/$steps_total] 🔑 Loading SSH keys..."
    if load_ssh_key $verbose; then
      colorize "[$current_step/$steps_total] ✓ SSH keys loaded successfully"
    else
      success=false
    fi
    ((current_step++))

    echo "[$current_step/$steps_total] 🔐 Loading GPG keys..."
    if load_gpg_key $verbose; then
      colorize "[$current_step/$steps_total] ✓ GPG keys loaded and agent configured"
      if ! gpg --list-secret-keys $(git config --global user.signingkey) >/dev/null 2>&1; then
        echo "  ↳ Reimporting GPG secret key..."
        reimport_secret_key $verbose $(git config --global user.signingkey) $(op item get "m3au gpg" --vault "Purr" --field password --reveal)
      fi
    else
      success=false
    fi
    ((current_step++))

    echo "[$current_step/$steps_total] 📝 Configuring Git signing..."
    if enable_git_signing $verbose; then
      colorize "[$current_step/$steps_total] ✓ Git signing configured successfully"
    else
      success=false
    fi
    ((current_step++))

    echo "[$current_step/$steps_total] 🔗 Setting up GitHub credentials..."
    if setup_github_credentials $verbose; then
      colorize "[$current_step/$steps_total] ✓ GitHub credentials configured successfully"
    else
      success=false
    fi

    if $success; then
      colorize "✨ All keys loaded, agents configured, and Git/GitHub setup complete"
      $verbose || colorize "ᓚᘏᗢ purr"
    else
      colorize "✗ Failed to complete key setup"
    fi
    ;;
  *)
    echo "Unknown command: $command"
    print_help
    return 1
    ;;
  esac
}


check_gpg_key() {
  local verbose=$1
  local gpg_key_id=$2

  $verbose && echo "➜ Starting GPG key status check..."
  $verbose && echo "➜ Checking public key presence..."


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

reimport_secret_key() {
  local verbose=$1
  local gpg_key_id=$2
  local password=$3

  $verbose && echo "➜ Starting secret key reimport process..."
  $verbose && echo "➜ Attempting to export existing secret key..."


  local export_output=$(gpg --batch --yes --passphrase "$password" --export-secret-keys "$gpg_key_id" 2>&1)
  if [ $? -ne 0 ]; then
    $verbose && echo "Failed to export secret key: $export_output"
    return 1
  fi


  local import_output=$(echo "$export_output" | gpg --batch --yes --passphrase "$password" --import 2>&1)
  $verbose && echo "Reimport output: $import_output"

  if echo "$import_output" | grep -q "secret key imported"; then
    $verbose && echo "Secret key successfully reimported."
    return 0
  else
    $verbose && echo "Failed to reimport secret key."
    return 1
  fi
}



setup_github_credentials() {
  local verbose=$1
  $verbose && echo "➜ Setting up GitHub credentials..."


  local github_user=$(op item get "GitHub" --vault "Purr" --field username)
  local github_email=$(op item get "GitHub" --vault "Purr" --field email)
  local github_pat=$(op item get "GitHub" --vault "Purr" --field pat --reveal)

  if [ -z "$github_user" ] || [ -z "$github_email" ] || [ -z "$github_pat" ]; then
    $verbose && echo "Failed to retrieve GitHub credentials from 1Password."
    return 1
  fi


  git config --global user.name "$github_user"
  git config --global user.email "$github_email"


  echo "protocol=https
host=github.com
username=$github_user
password=$github_pat" | git credential-osxkeychain store

  $verbose && echo "✓ GitHub credentials configured"
  return 0
}
