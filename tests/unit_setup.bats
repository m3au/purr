#!/usr/bin/env bats
# unit_setup.bats - idempotent setup, one 1Password read, and local health check

load test_helper

purr_test_after_setup() {
  export PATH="${BATS_TEST_DIRNAME}/mocks/bin:${PATH}"
  export PURR_OP_RETRY_DELAY=0
  mkdir -p "$TEST_TMPDIR/fixtures"
  printf '%s\n' "TEST123KEY456" > "$TEST_TMPDIR/gpg-import-id"
  : > "$TEST_TMPDIR/gpg-keys"
}

# Run purr in this shell so exports such as GITHUB_TOKEN stay visible.
run_purr() {
  set +e
  purr "$@" >"$TEST_TMPDIR/purr.out" 2>&1
  status=$?
  set -e
  output=$(cat "$TEST_TMPDIR/purr.out")
}

start_agent_socket() {
  python3 - "$PURR_SSH_AUTH_SOCK" << 'PY' &
import os
import socket
import sys
import time

path = sys.argv[1]
try:
    os.unlink(path)
except FileNotFoundError:
    pass
sock = socket.socket(socket.AF_UNIX)
sock.bind(path)
sock.listen(1)
time.sleep(120)
PY
  echo $! > "$TEST_TMPDIR/sock.pid"
  local i
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    if [ -S "$PURR_SSH_AUTH_SOCK" ]; then
      return 0
    fi
    sleep 0.05
  done
  echo "agent socket did not appear at $PURR_SSH_AUTH_SOCK" >&2
  return 1
}

write_gpg_fixture() {
  cat > "$TEST_TMPDIR/fixtures/gpg.json" << 'EOF'
{
  "title": "test-gpg",
  "fields": [
    {"label": "key_id", "value": "TEST123KEY456"},
    {"label": "password", "value": "test-passphrase"},
    {"label": "public_key", "value": "-----BEGIN PGP PUBLIC KEY BLOCK-----\nMock public\n-----END PGP PUBLIC KEY BLOCK-----"},
    {"label": "private_key", "value": "-----BEGIN PGP PRIVATE KEY BLOCK-----\nMock private\n-----END PGP PRIVATE KEY BLOCK-----"}
  ]
}
EOF
}

write_github_fixture() {
  cat > "$TEST_TMPDIR/fixtures/github.json" << 'EOF'
{
  "title": "test-github",
  "sections": [
    {
      "fields": [
        {"label": "username", "value": "testuser"},
        {"label": "email address", "value": "test@example.com"},
        {"label": "pat", "value": "ghp_test_token_value"}
      ]
    }
  ]
}
EOF
}

arrange_local_signing() {
  printf '%s\n' "TEST123KEY456" > "$TEST_TMPDIR/gpg-keys"
  git config --global user.name "testuser"
  git config --global user.email "test@example.com"
  git config --global user.signingkey "TEST123KEY456"
  git config --global commit.gpgsign true
  git config --global gpg.program "$(command -v gpg)"
  printf 'pinentry-program /opt/homebrew/bin/pinentry-mac\ndefault-cache-ttl %s\nmax-cache-ttl %s\n' \
    "$PURR_GPG_CACHE_TTL" "$PURR_GPG_CACHE_TTL" > "$GNUPGHOME/gpg-agent.conf"
}

op_calls() {
  if [ -f "$TEST_TMPDIR/op-args.log" ]; then
    grep -c . "$TEST_TMPDIR/op-args.log"
  else
    printf '0'
  fi
}

@test "json field reads the first matching label and keeps spaces" {
  local json='{"fields":[{"label":"key_id","value":"ABC"},{"id":"password","label":"password","value":"s e c r e t"},{"label":"pat","value":""},{"label":"token","value":"from-token"}]}'
  local value
  value=$(printf '%s' "$json" | purr_json_field key_id)
  [ "$value" = "ABC" ]
  value=$(printf '%s' "$json" | purr_json_field password)
  [ "$value" = "s e c r e t" ]
  value=$(printf '%s' "$json" | purr_json_field pat token)
  [ "$value" = "from-token" ]
}

@test "json field reads section fields and real newlines" {
  local json='{"sections":[{"fields":[{"label":"private_key","value":"line1\nline2"}]}]}'
  local value
  value=$(printf '%s' "$json" | purr_json_field private_key)
  [ "$value" = "$(printf 'line1\nline2')" ]
}

@test "mcp merge preserves other servers and escapes the token" {
  cat > "$HOME/.cursor/mcp.json" << 'EOF'
{"extra": true, "mcpServers": {"other": {"command": "keep"}}}
EOF
  purr_mcp_write_token 'say "hello"\path'
  [ "$PURR_STEP_STATUS" = "set" ]
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
data = json.load(open(sys.argv[1]))
assert data["extra"] is True
assert data["mcpServers"]["other"]["command"] == "keep"
assert data["mcpServers"]["github"]["env"]["GITHUB_PERSONAL_ACCESS_TOKEN"] == 'say "hello"\\path'
assert data["mcpServers"]["github"]["command"] == "npx"
PY
  purr_mcp_write_token 'say "hello"\path'
  [ "$PURR_STEP_STATUS" = "ok" ]
}

@test "ssh config is created once and uses a tilde for a home socket" {
  local original="$PURR_SSH_AUTH_SOCK"
  PURR_SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  purr_ensure_ssh_config
  [ "$PURR_STEP_STATUS" = "set" ]
  [ "$(grep -c '^  IdentityAgent ' "$HOME/.ssh/config")" -eq 1 ]
  grep -q 'IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"' "$HOME/.ssh/config"
  purr_ensure_ssh_config
  [ "$PURR_STEP_STATUS" = "ok" ]
  [ "$(grep -c '^  IdentityAgent ' "$HOME/.ssh/config")" -eq 1 ]
  PURR_SSH_AUTH_SOCK="$original"
}

@test "ssh config quotes a socket path that contains spaces" {
  local original="$PURR_SSH_AUTH_SOCK"
  PURR_SSH_AUTH_SOCK="$TEST_TMPDIR/Group Containers/agent.sock"
  purr_ensure_ssh_config
  grep -F "IdentityAgent \"$PURR_SSH_AUTH_SOCK\"" "$HOME/.ssh/config"
  PURR_SSH_AUTH_SOCK="$original"
}

@test "ssh config leaves a different IdentityAgent untouched" {
  printf 'Host *\n  IdentityAgent "/tmp/other-agent.sock"\n' > "$HOME/.ssh/config"
  if purr_ensure_ssh_config; then
    echo "expected ssh config update to fail" >&2
    return 1
  fi
  [[ "$PURR_LAST_ERROR" == *"/tmp/other-agent.sock"* ]]
  [ "$(grep -c IdentityAgent "$HOME/.ssh/config")" -eq 1 ]
  ! grep -q "Added by purr" "$HOME/.ssh/config"
}

@test "gpg agent ttl preserves other settings and reloads once" {
  printf 'pinentry-program /opt/homebrew/bin/pinentry-mac\ndefault-cache-ttl 600\n' > "$GNUPGHOME/gpg-agent.conf"
  purr_ensure_gpg_ttl
  [ "$PURR_STEP_STATUS" = "set" ]
  grep -q 'pinentry-program /opt/homebrew/bin/pinentry-mac' "$GNUPGHOME/gpg-agent.conf"
  [ "$(grep -c '^default-cache-ttl ' "$GNUPGHOME/gpg-agent.conf")" -eq 1 ]
  [ "$(grep -c '^max-cache-ttl ' "$GNUPGHOME/gpg-agent.conf")" -eq 1 ]
  grep -q "default-cache-ttl $PURR_GPG_CACHE_TTL" "$GNUPGHOME/gpg-agent.conf"
  grep -q -- '--reload gpg-agent' "$TEST_TMPDIR/gpgconf.log"
  : > "$TEST_TMPDIR/gpgconf.log"
  purr_ensure_gpg_ttl
  [ "$PURR_STEP_STATUS" = "ok" ]
  [ ! -s "$TEST_TMPDIR/gpgconf.log" ]
}

@test "fresh setup imports gpg with one json read and merges mcp.json" {
  start_agent_socket
  write_gpg_fixture
  write_github_fixture
  cat > "$HOME/.cursor/mcp.json" << 'EOF'
{
  "theme": "keep-me",
  "mcpServers": {
    "other": {
      "command": "other-server"
    }
  }
}
EOF

  run_purr
  [ "$status" -eq 0 ]
  [[ "$output" == *"imported secret key"* ]]
  [[ "$output" == *"purr"* ]]
  [ "$(grep -c 'item get test-gpg' "$TEST_TMPDIR/op-args.log")" -eq 1 ]
  [ "$(grep -c 'item get test-github' "$TEST_TMPDIR/op-args.log")" -eq 1 ]
  [ "$(op_calls)" -eq 2 ]
  grep 'item get test-gpg' "$TEST_TMPDIR/op-args.log" | grep -q -- '--format json'
  grep 'item get test-gpg' "$TEST_TMPDIR/op-args.log" | grep -q -- '--reveal'
  ! grep 'item get test-gpg' "$TEST_TMPDIR/op-args.log" | grep -q -- '--field'
  [ "$(git config --global user.signingkey)" = "TEST123KEY456" ]
  [ "$(git config --global commit.gpgsign)" = "true" ]
  [ -x "$(git config --global gpg.program)" ]
  [ "$(git config --global user.name)" = "testuser" ]
  [ "$(git config --global user.email)" = "test@example.com" ]
  grep -qx 'TEST123KEY456' "$TEST_TMPDIR/gpg-keys"
  [ "$(grep -c IdentityAgent "$HOME/.ssh/config")" -eq 1 ]
  [ "$GITHUB_TOKEN" = "ghp_test_token_value" ]
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
data = json.load(open(sys.argv[1]))
assert data["theme"] == "keep-me"
assert data["mcpServers"]["other"]["command"] == "other-server"
assert data["mcpServers"]["github"]["env"]["GITHUB_PERSONAL_ACCESS_TOKEN"] == "ghp_test_token_value"
PY

  run_purr
  [ "$status" -eq 0 ]
  [[ "$output" == *"already in the keyring"* ]]
  [ "$(op_calls)" -eq 2 ]
}

@test "configured machine does not call 1Password" {
  start_agent_socket
  purr_ensure_ssh_config
  arrange_local_signing
  printf '%s' 'ghp_fromgh000000000000' > "$TEST_TMPDIR/gh-token"
  printf '%s\n' 'cached' > "$TEST_TMPDIR/gpg-cached"

  run_purr
  [ "$status" -eq 0 ]
  [ "$(op_calls)" -eq 0 ]
  [[ "$output" == *"token from gh"* ]]
  [ "$GITHUB_TOKEN" = "ghp_fromgh000000000000" ]
  grep -q 'ghp_fromgh000000000000' "$HOME/.cursor/mcp.json"

  run purr check
  [ "$status" -eq 0 ]
  [[ "$output" == *"All checks passed."* ]]
  [[ "$output" == *"signed a throwaway string without prompting"* ]]
  [ "$(op_calls)" -eq 0 ]
}

@test "setup reuses a token already stored in mcp.json" {
  start_agent_socket
  purr_ensure_ssh_config
  arrange_local_signing
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
json.dump({
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_already_stored_token"}
    }
  }
}, open(sys.argv[1], "w"))
PY

  run_purr
  [ "$status" -eq 0 ]
  [ "$(op_calls)" -eq 0 ]
  [ "$GITHUB_TOKEN" = "ghp_already_stored_token" ]
  [[ "$output" == *"reused the token"* ]]
}

@test "1Password connection failure names the step" {
  start_agent_socket
  printf '%s\n' "[ERROR] error initializing client: connecting to desktop app: 1Password CLI couldn't connect to the 1Password desktop app" > "$TEST_TMPDIR/op-fail"
  run purr
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed: GPG key - "* ]]
  [[ "$output" == *"couldn't connect to the 1Password desktop app"* ]]
  [[ "$output" == *"Setup incomplete."* ]]
  [ "$(grep -c 'item get test-gpg' "$TEST_TMPDIR/op-args.log")" -eq 2 ]
}

@test "check reports missing local setup without 1Password" {
  run purr check
  [ "$status" -eq 1 ]
  [[ "$output" == *"SSH config"* ]]
  [[ "$output" == *"fail"* ]]
  [[ "$output" == *"check(s) failed."* ]]
  [ "$(op_calls)" -eq 0 ]
}

@test "invalid mcp.json is left unchanged" {
  start_agent_socket
  purr_ensure_ssh_config
  arrange_local_signing
  printf '%s' 'ghp_fromgh000000000000' > "$TEST_TMPDIR/gh-token"
  printf '%s\n' '{not json' > "$HOME/.cursor/mcp.json"
  run_purr
  [ "$status" -eq 0 ]
  [[ "$output" == *"not valid JSON"* ]]
  [ "$(cat "$HOME/.cursor/mcp.json")" = '{not json' ]
}

@test "lock unloads signing material and keeps other mcp servers" {
  start_agent_socket
  purr_ensure_ssh_config
  arrange_local_signing
  export GITHUB_TOKEN="ghp_lock_me_please"
  export SSH_AUTH_SOCK="$PURR_SSH_AUTH_SOCK"
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
json.dump({
  "mcpServers": {
    "github": {"command": "npx", "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_lock_me_please"}},
    "other": {"command": "keep"}
  }
}, open(sys.argv[1], "w"))
PY

  run_purr lock
  [ "$status" -eq 0 ]
  [[ "$output" == *"signed out of the CLI"* ]]
  [[ "$output" == *"IdentityAgent in ~/.ssh/config kept"* ]]
  [[ "$output" == *"hiss"* ]]
  [ -z "${GITHUB_TOKEN:-}" ]
  [ -z "$(git config --global user.signingkey || true)" ]
  [ "$(git config --global commit.gpgsign || true)" = "" ]
  [ ! -s "$TEST_TMPDIR/gpg-keys" ]
  grep -q 'IdentityAgent' "$HOME/.ssh/config"
  grep -q 'signout --all' "$TEST_TMPDIR/op-args.log"
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
data = json.load(open(sys.argv[1]))
assert "github" not in data["mcpServers"]
assert data["mcpServers"]["other"]["command"] == "keep"
PY
}

@test "lock deletes mcp.json when the github server is the only entry" {
  arrange_local_signing
  python3 - "$HOME/.cursor/mcp.json" << 'PY'
import json, sys
json.dump({"mcpServers": {"github": {"command": "npx", "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "x"}}}}, open(sys.argv[1], "w"))
PY
  run_purr lock
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.cursor/mcp.json" ]
}

@test "purr can be sourced from a zsh lazy-load wrapper" {
  command -v zsh >/dev/null || skip "zsh is not installed"
  run zsh -c "export HOME='${HOME}'; export GIT_CONFIG_GLOBAL='${GIT_CONFIG_GLOBAL}'; export GIT_CONFIG_NOSYSTEM=1; export GNUPGHOME='${GNUPGHOME}'; export PATH='${PATH}'; purr() { unfunction purr; source '${BATS_TEST_DIRNAME}/../purr.zsh'; purr \"\$@\"; }; purr -h"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: purr"* ]]
  [[ "$output" == *"check"* ]]
}

@test "direct execution is refused" {
  run zsh "${BATS_TEST_DIRNAME}/../purr.zsh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"sourced, not executed"* ]]
  run bash "${BATS_TEST_DIRNAME}/../purr.zsh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"sourced, not executed"* ]]
}
