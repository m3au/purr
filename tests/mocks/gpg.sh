#!/usr/bin/env bash
# Mock GPG for testing
case "$1" in
  --list-keys|--list-secret-keys)
    echo "pub   rsa4096 2024-01-01 [SC]"
    echo "      ABC123DEF4567890"
    echo "uid           [ultimate] Test User <test@example.com>"
    ;;
  --import) echo "gpg: key ABC123DEF4567890: imported" ;;
  --delete-secret-keys) ;;
esac
