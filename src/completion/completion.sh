#!/bin/sh

# TODO: Add support for other shells
if [ -n "$ZSH_VERSION" ]; then
  . "${PURR_HOME}/scripts/completion.zsh"
fi
