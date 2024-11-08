#!/usr/bin/env bash

set -euo pipefail

# Check arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <man-page-source> <output-dir>" >&2
    exit 1
fi

MAN_SOURCE="$1"
OUTPUT_DIR="$2"

# Extract commands and options from man page
extract_commands() {
    grep -A1 "^##" "$MAN_SOURCE" | \
    grep -v "^##" | \
    grep -v "^--" | \
    sed -e 's/^[[:space:]]*//' | \
    grep -v "^$"
}

# Generate bash completion
generate_bash_completion() {
    local outfile="$OUTPUT_DIR/completion.bash"

    cat > "$outfile" << 'EOF'
#!/usr/bin/env bash

_purr_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # List of all commands
    opts="$(extract_commands)"

    # Basic completion
    case "$prev" in
        purr)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _purr_completion purr
EOF

    chmod +x "$outfile"
}

# Generate zsh completion
generate_zsh_completion() {
    local outfile="$OUTPUT_DIR/completion.zsh"

    cat > "$outfile" << 'EOF'
#compdef purr

_purr() {
    local -a commands
    commands=(
        $(extract_commands | sed 's/\(.*\)/"\1"/')
    )

    _arguments \
        '1: :->command' \
        '*: :->args'

    case $state in
        command)
            _describe 'command' commands
            ;;
    esac
}

_purr "$@"
EOF

    chmod +x "$outfile"
}

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate completions
generate_bash_completion
generate_zsh_completion

echo "Generated completions in $OUTPUT_DIR:"
ls -l "$OUTPUT_DIR"
