#!/bin/bash
# Bash completion implementation

_purr_completion() {
    cur="$2"
    prev="$3"

    # Main commands
    commands="status keys lock install uninstall update doctor config backup reset verify version"

    # Subcommands for specific commands
    case "$prev" in
    "keys")
        compgen -W "list load unload" -- "$cur"
        return 0
        ;;
    "status")
        compgen -W "--keys --debug --check" -- "$cur"
        return 0
        ;;
    "config")
        compgen -W "get set list" -- "$cur"
        return 0
        ;;
    *)
        compgen -W "$commands" -- "$cur"
        return 0
        ;;
    esac
}

complete -F _purr_completion purr
