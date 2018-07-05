#!/bin/bash

# /!\ You must already be in current directory for this to work /!\

export GLOBALRC="$(pwd -P)"

### Begin custom functions ###

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

### End custom functions ###

# Login shell
if (running_shell zsh && [[ -o login ]]) || (running_shell bash && shopt -q login_shell); then
  # echo ".globalrc version" $(cat $GLOBALRC/version)
  # Display the logo
  cat logo
fi

# Testing Unicode environment
# Currently, this automatically fails on a non-amd64 arch. I should fix it. Yeah, I definitely should.
if [[ $(uname -m) = 'x86_64' ]] && scripts/unicode_test 2713 ; then
  export UNICODE_VALID=1
fi

# Disable flow control, to free C-S and C-Q
# cf https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
stty -ixon

### Begin definitions ###

# Add scripts to $PATH
if [ -d "$(pwd)/scripts" ] ; then
  PATH="$(pwd)/scripts:$PATH"
fi

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

# ls extra colors
LS_COLORS="$LS_COLORS*.JPG=01;35:*.GIF=01;35:*.jpg=01;35:*.gif=01;35:*.jpeg=01;35:*.pcx=01;35:*.png=01;35:*.pnm=01;35:*.bz2=01;31:*.mpg=01;38:*.mpeg=01;38:*.MPG=01;38:*.MPEG=01;38:*.m4v=01;038:*.mp4=01;038:*.swf=01;038:*.avi=01;38:*.AVI=01;38:*.wmv=01;38:*.WMV=01;38:*.asf=01;38:*.ASF=01;38:*.mov=01;38:*.MOV=01;38:*.mp3=01;39:*.ogg=01;39:*.MP3=01;39:*.Mp3=01;39"

### End definitions ###

### Begin aliases ###

# ls variants
alias ls='ls --color=auto'
alias ll='ls -Alh'

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

# alias to load screen config file
# TODO: do this through ansible
alias screen='screen -c $GLOBALRC/screenrc'

# sudo shell with environment
alias ssudo='sudo -sE'

# maj
if [ "$(which apt-get 2> /dev/null)" ]; then
  alias maj='sudo apt-get update && sudo apt-get dist-upgrade'
fi

# 10 biggest files/directories in current directory
alias topten='du -sk $(/bin/ls -A) | sort -rn | head -10'

# tree from current directory
alias tree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"

# Use sshrc by default
# We use an alias so that it doesn't get called when not directly typed by the user
alias ssh="sshrc"
if [ -x /usr/bin/mosh ]; then
  alias mosh="moshrc"
fi

# Docker aliases
alias stop_docker="docker ps | awk '{ print \$1 }' | grep -v '^CONTAINER' | xargs docker stop"

# Imperial march on buzzer
alias imperial-march="beep -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 350 -f 587.32 -D 100 --new -l 250 -f 622.26 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.1 -D 100 --new -l 25 -f 466.2 -D 100 --new -l 700 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 369.99 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 466.16 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 587.32 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 392 -D 100 --new -l 25 -f 392 -D 100 --new -l 350 -f 784 -D 100 --new -l 250 -f 739.98 -D 100 --new -l 25 -f 698.46 -D 100 --new -l 25 -f 659.26 -D 100 --new -l 25 -f 622.26 -D 100 --new -l 50 -f 659.26 -D 400 --new -l 25 -f 415.3 -D 200 --new -l 350 -f 554.36 -D 100 --new -l 250 -f 523.25 -D 100 --new -l 25 -f 493.88 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 25 -f 440 -D 100 --new -l 50 -f 466.16 -D 400 --new -l 25 -f 311.13 -D 200 --new -l 350 -f 392 -D 100 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 300 -f 392.00 -D 150 --new -l 250 -f 311.13 -D 100 --new -l 25 -f 466.16 -D 100 --new -l 700 -f 392"

### End aliases ###
