#!/usr/bin/env bash
# Mock Git for testing
case "$1" in
  config)
    shift
    case "$1" in
      --global)
        shift
        case "$1" in
          user.name|user.email|user.signingkey|commit.gpgsign)
            [[ $# -eq 3 ]] && echo "$3" || echo ""
            ;;
          --unset)
            shift
            echo "unset $1"
            ;;
          --list)
            echo "user.signingkey=ABC123DEF4567890"
            echo "commit.gpgsign=true"
            ;;
        esac
        ;;
    esac
    ;;
esac
