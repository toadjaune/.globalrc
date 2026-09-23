# To get started with your own zshrc, start with the following script :
# (it is the one run by default by zsh at shell startup if you have no zshrc)
# `zsh /usr/share/zsh/functions/Newuser/zsh-newuser-install -f`
#
# Many options here were extracted from gmrl conf. See https://grml.org/zsh/

# Loading common components
# Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
source $HOME/.globalrc/files/bazshrc.sh

# Expand fpath to include custom functions
fpath=(
  "$HOME/.globalrc/files/zsh_fpath"     # custom scripts
  $fpath                                # default fpath
  "$HOME/.globalrc/generated_zsh_fpath" # extra generated completions
)
# Autoload custom functions defined in zsh_fpath
autoload bonjour ff mkcd pub

### Begin various configuration ###

# For `setopt` possible values and documentation, see : http://zsh.sourceforge.net/Doc/Release/Options.html
# For history variables, see : http://zsh.sourceforge.net/Guide/zshguide02.html#l17

# Allow help
autoload -U run-help
autoload run-help-git

# zmv is a mass-rename tool
autoload zmv

# Add commands to history file directly at execution time
setopt inc_append_history_time

# Store commands in history without extraneous spaces
setopt hist_reduce_blanks

# Report about cpu-/system-/user-time of command if running longer than 5 seconds
REPORTTIME=5

# Print a message every time somebody else than me logs in/out
watch=notme

# if a command is issued that can't be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt auto_cd

# display PID when suspending processes as well
setopt long_list_jobs

# make cd push the old directory onto the directory stack.
setopt auto_pushd

# avoid "beep"ing
setopt no_beep

# don't push the same dir twice.
setopt pushd_ignore_dups

### End various configuration ###



### Begin completion pre-configuration ###

# See https://linux.die.net/man/1/zshcompsys for explanation

# Sane defaults

# compinstall-generated : Default description when 1 argument and not specified by completion function
zstyle ':completion:*' auto-description 'specify: %d'
# compinstall-generated : Configures the completion functions to call (unclear)
zstyle ':completion:*' completer _complete _ignored _correct _approximate
# compinstall-generated : Used to merge some completion groups
zstyle ':completion:*' group-name ''
# compinstall-generated : Define patterns used for matching completions (unclear)
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'
# compinstall-generated : Only display the original string if there's more than one possible match
zstyle ':completion:*' original false
# compinstall-generated : Do not allow completion definitions from the legacy compctl system
zstyle ':completion:*' use-compctl false
# compinstall-generated : Use LS_COLORS to colors completions (TODO : Somehow enable this, it sounds nice)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# compinstall-generated : If there's only one valid completion, insert it directly without menu
zstyle ':completion:*' insert-unambiguous true


# Menu and related options

# The setting below (menu-completion disabled) in case of too many options will, on each Tab press :
# 1 - display a single line indicating the number of options, and asking whether we want to print them all
# 2 - print all options at once, then print back the normal shell prompt
# 3 - enter menu mode
#
# TODO :
# * Find a way so that, whenever there are too many options, the initial list printing (steps 1 and 2) is skipped, and we directly go to menu

# Defining this would allow, in case the completion list is too long to fit on screen, to scroll through it and define corresponding prompt
# We don't want that, as in this case, we'll rely on the menu, and we'd rather have a consistent (and smaller) number of tab-presses required to reach the menu
# zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle -d ':completion:*' list-prompt

# enable menu completion if there are at least 5 options, or they don't fit on screen, and allow searching through options if you type stuff before any extra tab or arrow key presses
# interactive instead of search would be nicer (it filters the options on screen) but it completely disables tab-selection, which is a nogo (TODO : is there a way around this limitation ?)
zstyle ':completion:*' menu select=5 select=long-list search

# Title of different completion categories, used both in initial and menu listing (e.g. see with `git switch` completion to get an example of sections, with local and remote branch names)
zstyle ':completion:*' format '### completing %d ###'

# Used by _correct and _approximate above to find completions, uses levenshtein distance to count a maximum of typing errors allowed
zstyle ':completion:*' max-errors 2 numeric
# compinstall-generated : Similar to list-prompt, but for menu. (TODO : clarify and/or disable)
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'


# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                           /usr/local/bin  \
                                           /usr/sbin       \
                                           /usr/bin        \
                                           /sbin           \
                                           /bin            \
                                           /usr/X11R6/bin

# host completion
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()

hosts=(
    $(hostname)
    "$_ssh_config_hosts[@]"
    "$_ssh_hosts[@]"
    "$_etc_hosts[@]"
    localhost
)
zstyle ':completion:*:hosts' hosts $hosts

### End completion pre-configuration ###



### Begin custom stuff ###

# IRC-client-like input, to store in history a partial command
# cf http://www.zshwiki.org/home/zle/ircclientlikeinput
# /!\ This probably won't work if done after other widget
# changes affecting down-line-or-history

fake-accept-line() {
  if [[ -n "$BUFFER" ]];
  then
    print -S "$BUFFER"
  fi
  return 0
}
zle -N fake-accept-line

down-or-fake-accept-line() {
  if (( HISTNO == HISTCMD )) && [[ "$RBUFFER" != *$'\n'* ]];
  then
    zle fake-accept-line
  fi
  zle .down-line-or-history "$@"
}
zle -N down-line-or-history down-or-fake-accept-line

# Just use G to pipe to grep
# NB: this only expands in the case of space-separated G alone
# See alias, in `man zshbuiltins`
alias -g G='| grep'

### End custom stuff ###

###############################################################################
# Plugins pre-configuration                                                   #
###############################################################################

### powerlevel10k ###

# https://starship.rs/ might be an alternative later on, it does have some pretty nice features :
# * Simpler configuration
# * Possibly crazy fast
# But for now, it is entirely synchronous, and at least git status may be pretty slow :
# https://github.com/starship/starship/issues/301

# file generated with `p10k configure`
# Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
source $HOME/.globalrc/files/p10k.zsh

###############################################################################

### List of plugins ###

# Community packaging of completions for common programs
# Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
fpath=($HOME/.globalrc/zsh_plugins/zsh-completions/src $fpath)

# We both need 256 colors support, and a patched font, for p10k to work normally
# TODO : the detection logic for the vscode case is probably quite brittle. It seems to work for now, though.
if [[ -n $GLOBALRC_256_COLORS && (-n $GLOBALRC_PATCHED_FONT || $TERM_PROGRAM == "vscode") ]]; then
  # Powerlevel10k, prompt configuration
  # Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
  source "$HOME/.globalrc/zsh_plugins/powerlevel10k/powerlevel10k.zsh-theme"
else
  # Just load legacy prompt
  # Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
  source "$HOME/.globalrc/zsh_prompt.zsh"
fi
