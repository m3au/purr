#!/bin/zsh
# Zsh completion implementation

_purr() {
    local -a commands
    local -a subcommands

    commands=(
        'status:Show current state'
        'keys:Manage SSH and GPG keys'
        'lock:Unload keys and lock'
        'install:Install purr'
        'uninstall:Remove purr'
        'update:Update purr'
        'doctor:Run diagnostics'
        'config:Manage configuration'
        'backup:Backup configuration'
        'reset:Reset configuration'
        'verify:Verify installation'
        'version:Show version'
    )

    case "${words[2]}" in
    keys)
        subcommands=('list:List loaded keys' 'load:Load a key' 'unload:Unload a key')
        _describe -t commands 'purr keys' subcommands
        ;;
    status)
        subcommands=('--keys:List keys' '--debug:Show debug info' '--check:Check status')
        _describe -t commands 'purr status' subcommands
        ;;
    config)
        subcommands=('get:Get config value' 'set:Set config value' 'list:List config')
        _describe -t commands 'purr config' subcommands
        ;;
    *)
        _describe -t commands 'purr' commands
        ;;
    esac
}

compdef _purr purr
