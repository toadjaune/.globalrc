#!/bin/bash

# /!\ You must already be in current directory for this to work /!\

export GLOBALRC="$(pwd -P)"

### Begin utility functions ###

# repeat n times command
function repeat()
{
  local i max
  max=$1; shift;
  for ((i=1; i <= max ; i++)); do
    eval "$@";
  done
}

# Find a file with a pattern in name - dans le rep local:
function ff() { find . -type f -iname '*'$*'*' -ls ; }


# change window title
t () {
  echo -ne "\\e]2;$1\\a"
}

# Correct filenames to lowercase
function fn_to_lowercase()
{
  if [ "$#" = 0 ]
  then
    echo "Usage: fn_to_lowercase [filenames...]"
    return 0
  fi

  for arg in "$@"; do
    filename=`basename "$arg"`
    dirname=`dirname "$arg"`
    oldname=`echo "$filename" | sed -e "s/ /\\\\ /"`
    newname=`echo "$filename" | tr A-Z a-z`
    if [ ! -e "$dirname/$oldname" ];
    then
      echo "$dirname/$oldname does not exists."
    elif [ "$oldname" = "$newname" ]
    then
      echo "$dirname/$oldname needs no change, skipping..."
    elif [ -e "$dirname/$newname" ]
    then
      echo "$dirname/$newname exists, skipping..."
    else
      mv "$dirname/$oldname" "$dirname/$newname"
      echo "$dirname/$oldname => $dirname/$newname"
    fi
  done
}

# Correct spaces in filenames
function fn_no_spaces()
{
  if [ "$#" = 0 ]
  then
    echo "Usage: fn_no_spaces [filenames...]"
    return 0
  fi

  for arg in "$@"
  do
    filename=`basename "$arg"`
    dirname=`dirname "$arg"`
    oldname=`echo "$filename" | sed -e "s/ /\\\\ /"`
    newname=`echo "$filename" | sed -e : -e s/\ /_/ -e s/%20/_/ -e s/%28/[/ -e s/%29/]/ -e s/%5B/[/ -e s/
    %5D/]/ -e t`
    if [ ! -e "$dirname/$oldname" ];
    then
      echo "$dirname/$oldname does not exists."
    elif [ "$oldname" = "$newname" ]
    then
      echo "$dirname/$oldname needs no change, skipping..."
    elif [ -e "$dirname/$newname" ]
    then
      echo "$dirname/$newname exists, skipping..."
    else
      mv "$dirname/$oldname" "$dirname/$newname"
      echo "$dirname/$oldname => $dirname/$newname"
    fi
  done
}

# For fun. Totally useless, but I couldn't just throw it away
bonjour (){
  local rnd
  rnd=$[RANDOM%4]

  case $rnd in
    0 )
      echo "Bonjour Maître vénéré"
      ;;
    1 )
      echo "Quel plaisir de vous revoir Grand Maître!"
      ;;
    2 )
      echo "Maître tout puissant, je vous salue"
      ;;
    3 )
      echo "Mon Maître, je suis à vos ordres"
      ;;
  esac
}

# Get your public IP
pub(){
  ip_site="http://whatismyip.akamai.com"

  if [ "$(which wget)" ]; then
    wget -O - -q $ip_site
  elif [ "$(which curl)" ]; then
    curl $ip_site
  elif [ "$(which lynx)" ]; then
    lynx --dump $ip_site
  elif [ "$(which dig)" ]; then
    dig +short myip.opendns.com @resolver1.opendns.com
  else
    >&2 echo "Couldn't find any program to get a webpage"
    exit 1
  fi
}

genpasswd() {
  local l=$1
    [ "$l" == "" ] && l=20
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

running_shell() {
  basename -- "${0#-}" | grep $1 >/dev/null
}

### End utility functions ###

### Begin test of terminal capabilities and configuration ###

# For terminal capabilities, we shouldn't rely on $TERM, instead, make a lookup in the terminfo database, cf :
# - https://unix.stackexchange.com/a/9960/293790
# - http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
# - man terminfo
# (And obviously, changing $TERM yourself is TERRIBLY WRONG)
# TODO: Forward the terminal capabilities over ssh (forwarding $TERM and $TERMCAP ?)

# Test for 256colors support
# NB : I'm not certain if `tput colors` can output a value higher than 256, which would break this test
# run `for code in {000..255}; do print -P -- "$code: %F{$code}Test%f"; done` to see possible colors
[[ $(tput colors) == '256' ]] && export GLOBALRC_256_COLORS='1'

# Testing Unicode environment
# Currently, this automatically fails on a non-amd64 arch. I should fix it. Yeah, I definitely should.
if [[ $(uname -m) = 'x86_64' ]] && scripts/unicode_test 2713 ; then
  export UNICODE_VALID=1
fi

# Disable flow control, to free C-S and C-Q
# cf https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
stty -ixon

### End test of terminal capabilities and configuration ###

# Login shell
if (running_shell zsh && [[ -o login ]]) || (running_shell bash && shopt -q login_shell); then
  # echo ".globalrc version" $(cat $GLOBALRC/version)
  # Display the logo
  cat logo
fi

### Begin definitions ###

# Add scripts to $PATH
PATH="{{ remote_directory }}/local_bin/:{{ remote_directory }}/files/scripts/:$PATH"

if [ -x /usr/bin/most ]; then
  export PAGER="/usr/bin/most"
fi

if [ -x /usr/bin/vim ]; then
  export EDITOR="vim"
fi

# Use custom inputrc
export INPUTRC="$GLOBALRC/../templates/inputrc"

# Use custom sshrc location
export SSHHOME="$GLOBALRC/sshrc"

# Make agent-forwarding work even when reattaching screen/tmux
# NB : In case of multiple simultaneous connections with ssh agent forwarding
# to the same server as the same user, only the last to connect can be used
# cf : https://superuser.com/questions/180148/how-do-you-get-screen-to-automatically-connect-to-the-current-ssh-agent-when-re/424588#424588
# Note that since we skip if it this is already a symlink, it notably won't change in case of sudo -sE
if [ -S "$SSH_AUTH_SOCK" ] && [ ! -h "$SSH_AUTH_SOCK" ]; then
  ln -sf "$SSH_AUTH_SOCK" "{{ ssh_auth_sock }}"
  export SSH_AUTH_SOCK="{{ ssh_auth_sock }}"
fi

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

# Git with a self-signed certificate
alias gitc='git -c http.sslVerify=false'

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
if [ -x /usr/bin/vimx ]; then alias vim='/usr/bin/vimx'; fi

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
if [ -x /usr/bin/mosh ]; then
  alias mosh="moshrc"
fi
alias ls="exa --git"
alias ll="exa --git -al"

# Docker aliases
alias stop_docker="docker ps | awk '{ print \$1 }' | grep -v '^CONTAINER' | xargs docker stop"

# Imperial march on buzzer
alias imperial-march="beep -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 250 -f 622.26 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 466.16 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 587.32 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 300 -f 392.00 -D 150 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 392"

### End aliases & alias functions ###
