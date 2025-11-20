#!/usr/bin/env bash
# Mock 1Password CLI for testing
MOCK_VAULT="${PURR_VAULT_NAME:-purr}"
MOCK_GPG_ITEM="${PURR_GPG_ITEM:-gpg}"
MOCK_GITHUB_ITEM="${PURR_GITHUB_ITEM:-GitHub}"

case "$1" in
  account)
    case "$2" in
      get) echo '{"url":"https://test.1password.com","email":"test@example.com"}' ;;
      *) exit 1 ;;
    esac
    ;;
  item)
    case "$2" in
      get)
        shift 2
        item=""
        vault=""
        field=""
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --vault) vault="$2"; shift 2 ;;
            --field) field="$2"; shift 2 ;;
            *) item="$1"; shift ;;
          esac
        done
        case "$item" in
          "$MOCK_GPG_ITEM"|gpg)
            case "$field" in
              key_id) echo "ABC123DEF4567890" ;;
              password|passphrase) echo "mock-passphrase" ;;
              public_key) echo "-----BEGIN PGP PUBLIC KEY BLOCK-----" ;;
              private_key) echo "-----BEGIN PGP PRIVATE KEY BLOCK-----" ;;
            esac
            ;;
          "$MOCK_GITHUB_ITEM"|GitHub)
            case "$field" in
              username|user|login) echo "mock-user" ;;
              email|mail) echo "mock@example.com" ;;
              pat|token|password) echo "ghp_mocktoken1234567890" ;;
            esac
            ;;
        esac
        ;;
    esac
    ;;
  signin) echo 'export OP_SESSION_test="mock"' ;;
  signout) ;;
esac
