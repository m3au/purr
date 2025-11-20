#!/usr/bin/env bash
# Mock 1Password CLI for testing

op() {
  case "$1" in
    "account")
      if [ "$2" = "get" ]; then
        echo '{"url": "https://test.1password.com", "email": "test@example.com"}'
        return 0
      fi
      ;;
    "item")
      if [ "$2" = "get" ]; then
        local item_name="$4"
        local field_name="$8"
        
        # Mock GPG item
        if [ "$item_name" = "test-gpg" ] || [ "$item_name" = "gpg" ]; then
          case "$field_name" in
            "key_id")
              echo "TEST123KEY456"
              ;;
            "password")
              if [ "$9" = "--reveal" ]; then
                echo "test-passphrase"
              else
                echo "test-passphrase"
              fi
              ;;
            "public_key")
              echo "-----BEGIN PGP PUBLIC KEY BLOCK-----\nMock public key\n-----END PGP PUBLIC KEY BLOCK-----"
              ;;
            "private_key")
              echo "-----BEGIN PGP PRIVATE KEY BLOCK-----\nMock private key\n-----END PGP PRIVATE KEY BLOCK-----"
              ;;
          esac
        fi
        
        # Mock GitHub item
        if [ "$item_name" = "test-github" ] || [ "$item_name" = "GitHub" ]; then
          case "$field_name" in
            "username"|"user"|"login")
              echo "testuser"
              ;;
            "email"|"mail"|"email address")
              echo "test@example.com"
              ;;
            "pat"|"token"|"access token"|"personal access token"|"password")
              if [ "$9" = "--reveal" ]; then
                echo "ghp_test1234567890abcdef"
              else
                echo "ghp_test1234567890abcdef"
              fi
              ;;
          esac
        fi
      fi
      ;;
    "signin")
      echo "OP_SESSION_test=\"mock-session-token\""
      export OP_SESSION_test="mock-session-token"
      return 0
      ;;
    "signout")
      unset OP_SESSION_test
      return 0
      ;;
  esac
}

op "$@"
