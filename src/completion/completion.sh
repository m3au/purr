#!/bin/sh
# Shell completion loader

# Source the appropriate completion file based on shell
if [ -n "$BASH_VERSION" ]; then
  . "${PURR_HOME}/scripts/completion.bash"
elif [ -n "$ZSH_VERSION" ]; then
  . "${PURR_HOME}/scripts/completion.zsh"
fi
