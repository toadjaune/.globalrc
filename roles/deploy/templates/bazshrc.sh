#!/bin/bash

### Begin test of terminal capabilities and configuration ###

# For terminal capabilities, we shouldn't rely on $TERM, instead, make a lookup in the terminfo database, cf :
# - https://unix.stackexchange.com/a/9960/293790
# - http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
# - man terminfo
# - termcap is an older mechanism for this, use terminfo when possible
# (And obviously, changing $TERM yourself is TERRIBLY WRONG)
# TODO: Forward the terminal capabilities over ssh (forwarding $TERM ?)

# Test for 256colors support
# NB : I'm not certain if `tput colors` can output a value higher than 256, which would break this test
# run `for code in {000..255}; do print -P -- "$code: %F{$code}Test%f"; done` to see possible colors
if [[ $(tput colors) == '256' ]] ; then
  export GLOBALRC_256_COLORS='1'
fi

### End test of terminal capabilities and configuration ###

### Begin definitions ###

# Add scripts to $PATH
PATH="{{ remote_directory }}/local_bin/:{{ remote_directory }}/files/scripts/:$PATH"

if command -v most >/dev/null 2>&1 ; then
  export PAGER="most"
fi

if command -v vim >/dev/null 2>&1 ; then
  export EDITOR="vim"
fi

# Use custom inputrc
export INPUTRC="{{ remote_directory }}/templates/inputrc"

# Use custom sshrc location
export SSHHOME="{{ remote_directory }}/files/sshrc"

# SSH-agent setup, cf ssh-agent.service file
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

# Make agent-forwarding work even when reattaching screen/tmux
# NB : In case of multiple simultaneous connections with ssh agent forwarding
# to the same server as the same user, only the last to connect can be used
# cf : https://superuser.com/questions/180148/how-do-you-get-screen-to-automatically-connect-to-the-current-ssh-agent-when-re/424588#424588
# Note that since we skip if it this is already a symlink, it notably won't change in case of sudo -sE
#
# However, it makes mounting the socket in a docker impossible. Since it's not really used, disabled for now
# if [ -S "$SSH_AUTH_SOCK" ] && [ ! -h "$SSH_AUTH_SOCK" ]; then
#   ln -sf "$SSH_AUTH_SOCK" "{{ ssh_agent_symlink_path }}"
#   export SSH_AUTH_SOCK="{{ ssh_agent_symlink_path }}"
# fi

### End definitions ###

### Begin aliases & alias functions ###

# add colors to grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias rgrep='rgrep --color=auto'

# security aliases
alias rm='rm --preserve-root'
alias shred='shred -n 35 -z -u -v'

# Movements to parent directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Create a temporary directory and move to it
alias cdtmp='pushd $(mktemp -d)'

# History-related commands
alias h='history'
# This re-executes the last command, writes the output in a file descriptor, and opens it with vim,
# thanks to process substitution
# This syntax is compatible with both bash and zsh (unlike `fc -s`)
# See :
# - http://www.gnu.org/software/bash/manual/bashref.html#Bash-History-Builtins
# - http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html
# - https://www-s.acm.illinois.edu/workshops/zsh/history/fc.html
# - http://tldp.org/LDP/abs/html/process-sub.html
alias invim='vim <(fc -e true)'

# On RedHat family systems, use vimx if installed, to have access to clipboard from vim
if command -v vimx >/dev/null 2>&1 ; then alias vim='vimx'; fi

# Open big files with a minimal vim configuration
# TODO : see if we can have vim do this automatically based on file size
# TODO : We should probably use a separate profile for that, with specific options enabled/disabled (swapfiles, etc…)
alias bigvim='vim -u "NONE"'

# sudo shell with environment
alias ssudo='sudo -sE'

# use prettyping if installed
if command -v prettyping &>/dev/null; then
  alias ping=prettyping
fi

# maj
if [ "$(which apt-get 2> /dev/null)" ]; then
  alias maj='sudo apt-get update && sudo apt-get dist-upgrade'
fi

# 10 biggest files/directories in current directory
alias topten='du -sk $(/bin/ls -A) | sort -rn | head -10'

# tree from current directory
alias tree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"

# Use sshrc and exa by default
# We use an alias so that it doesn't get called when not directly typed by the user
alias ssh="sshrc"
alias ls="exa --git"
alias ll="exa --git -al"
if command -v mosh >/dev/null 2>&1 ; then
  alias mosh="moshrc"
fi

# SSH without sshrc nor host key checking
alias rescue_ssh="\ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Way too long commands
alias tf="terraform"

# Docker aliases
alias stop_docker="docker ps | awk '{ print \$1 }' | grep -v '^CONTAINER' | xargs docker stop"

# Imperial march on buzzer
alias imperial-march="beep -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 250 -f 622.26 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 466.16 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 587.32 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 300 -f 392.00 -D 150 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 392"

### End aliases & alias functions ###
