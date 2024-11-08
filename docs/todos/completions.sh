#!/bin/bash

set -eu

MAN_FILE="$1"
OUTPUT_DIR="${2:-dist/completion}"  # Default to dist/completion

mkdir -p "$OUTPUT_DIR"

# Extract commands directly into a variable
COMMANDS=$(go-md2man -in "$MAN_FILE" | \
    sed -n '/^COMMANDS/,/^[A-Z]/p' | \
    awk '/^[a-z]/ {cmd=$1; next} /^[[:space:]]+/ {sub(/^[[:space:]]+/, ""); print cmd " " $0}' | \
    grep -v '^[A-Z]' || echo "status Show current state")  # Default if extraction fails

# Generate zsh completion
cat > "$OUTPUT_DIR/completion.zsh" <<EOF
#compdef purr

_purr() {
  local -a commands
  commands=(
$(echo "$COMMANDS" | while read -r cmd desc; do
  echo "    \"$cmd:$desc\""
done)
  )

  _arguments -C \
    '(-h --help)'{-h,--help}'[Show help message]' \
    '(-v --verbose)'{-v,--verbose}'[Show detailed output]' \
    '(-V --version)'{-V,--version}'[Show version information]' \
    '*:: :->command' && return

  if (( CURRENT == 1 )); then
    _describe -t commands 'purr commands' commands
    return
  fi
}

_purr "\$@"
EOF

# Generate bash completion
cat > "$OUTPUT_DIR/completion.bash" <<EOF
#!/bin/bash

_purr() {
  local cur prev commands
  COMPREPLY=()
  cur="\${COMP_WORDS[COMP_CWORD]}"
  prev="\${COMP_WORDS[COMP_CWORD-1]}"

  commands="$(echo "$COMMANDS" | cut -d' ' -f1 | tr '\n' ' ')"

  case "\$prev" in
    purr)
      COMPREPLY=( \$(compgen -W "\$commands" -- "\$cur") )
      return 0
      ;;
  esac
}

complete -F _purr purr
EOF

echo "Generated shell completions in $OUTPUT_DIR"
