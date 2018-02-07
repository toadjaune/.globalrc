#!/usr/bin/zsh

if [[ -e $ZDOTDIR_ORIG/.zshrc ]]; then
  source $ZDOTDIR_ORIG/.zshrc
fi

# Load the configuration common with bash
source "$SSHHOME/.sshrc"

source "$ZDOTDIR/prompt.zsh"
