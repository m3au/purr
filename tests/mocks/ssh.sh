#!/usr/bin/env bash
# Mock SSH for testing
case "$1" in
  -l|--list)
    echo "4096 SHA256:mock-key /path/to/key (RSA)"
    ;;
esac
