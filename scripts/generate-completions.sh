#!/bin/bash

set -eu

COMMANDS_FILE="$1"
OUTPUT_DIR="$(dirname "$COMMANDS_FILE")"

# Generate zsh completion
cat > "$OUTPUT_DIR/completion.zsh" <<EOF
#compdef purr

_purr() {
  local -a commands
  commands=(
$(while read -r cmd desc; do
  echo "    \"$cmd:$desc\""
done < "$COMMANDS_FILE")
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

  commands="$(cut -d' ' -f1 "$COMMANDS_FILE" | tr '\n' ' ')"

  case "\$prev" in
    purr)
      COMPREPLY=( \$(compgen -W "\$commands" -- "\$cur") )
      return 0
      ;;
  esac
}

complete -F _purr purr
EOF
