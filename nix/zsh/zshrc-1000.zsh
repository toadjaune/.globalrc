
# Fish-like syntax highlighting
# NB : MUST be sourced after compinit (and as late as possible)
# NB : The highlighting gets slow on large buffers.
# Load legacy ansible-managed template as a transition mechanism (TODO: migrate)
source "$HOME/.globalrc/zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

### Inline atuin widget initialization ###

# Inline the contents of the atuin initialization command
# NB: We explicitly ask atuin NOT to setup keybindings, so that we can define them ourselves as we want to (although current config is default)
# NB: atuin init is so fast to run that doing this is probably not much of a performance gain. It still improves debuggability though, and might
#     play nicer with the zsh config loading cache ?
# NB: atuin has an integration with zsh-autosuggestions, enabled by default ONLY if this conf is loaded after zsh-autosuggestions
#     TODO: This wasn't tested to still be the case after migrating the widget setup to home-manager, test again
# TODO : we can probably disable native zsh history altogether, now that we have this

# Generated with : {{ atuin_init_zsh.cmd | join(" ") }}

# Since this currently still relies on ansible to retrieve the command output, it's not migrated yet.
# Begin generated content
# {{ atuin_init_zsh.stdout }}
# End generated content


### End inline atuin widget initialization ###

###############################################################################
# Plugins post-configuration                                                  #
###############################################################################

### zsh-syntax-highlighting ###
# Main highlight configuration (not all available options)
ZSH_HIGHLIGHT_STYLES+=(
  unknown-token         'fg=red,bold'
  reserved-word         'fg=yellow'
  alias                 'fg=green,bold'
  builtin               'fg=green,bold'
  function              'fg=green,bold'
  command               'fg=green,bold'
  precommand            'fg=green'
  hashed-command        'fg=green'
  path                  'fg=blue,bold'
  path_prefix           'fg=blue'
  path_approx           'fg=blue,underlined'
  globbing              'fg=yellow,underlined'
  single-hyphen-option  'fg=purple,bold'
  double-hyphen-option  'fg=purple,bold'
  back-quoted-argument  'fg=purple,bold'
  default               'fg=cyan,bold'
)

### zsh-autosuggestions ###
ZSH_AUTOSUGGEST_USE_ASYNC=1         # fetch suggestions asynchronously (only required for zsh < 5.0.8, default afterwards)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=200 # Disable suggestions past a certain command length

# We're not savages so we manually bind the wigets once, at initialization, instead of at every single precmd
# This MUST be executed after all other zle widget initializations
# zsh-autosuggest creates a precmd (_zsh_autosuggest_start) that, which, by default, will re-wrap every zle widget (_zsh_autosuggest_bind_widgets)
# at EVERY precmd. We're not savages, so we disable this. Instead, it will only run it at the very first precmd, then unregister itself.
# There is therefore no need to manually call _zsh_autosuggest_bind_widgets at init time, only if we were to define new widgets later on.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# NB: We used to have compatibility issues with zsh-syntax-highlighting, leading to an unmerged PR that we used as fork for a long time (https://github.com/zsh-users/zsh-autosuggestions/pull/749),
#     but it looks like this issue disappeared now that zsh-syntax-highlighting uses zle hooks instead of wrapping widgets.
#     Still, this issue could reappear if we needed to wrap any widget starting with an underscore, so, document it here at the very least

# NB: It's quite likely possible to replace this system (wrapping all zle widgets) with a zle-line-pre-redraw hook, just like zsh-syntax highlighting, but it's not really supported yet
#     https://github.com/zsh-users/zsh-autosuggestions/issues/529

###############################################################################


### Start key mappings ###

# Switch to vi keymaps
bindkey -v

# Key mappings common to several keymaps
keymap_list=('viins' 'vicmd' 'visual')

# # Mappings obsoleted by having an awesome keyboard
#
# for keymap in $keymap_list; do
#   # Aliasing movement keys (With Alt) to arrow keys
#   # NB: Mapping to arrow keys instead of directly to corresponding
#   # zle widgets is convenient, because it uses every default mapping
#   # to these arrows
#   # See http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
#   bindkey -M $keymap -s '^[{{ key_rh_left  }}' '^[[D'
#   bindkey -M $keymap -s '^[{{ key_rh_down  }}' '^[[B'
#   bindkey -M $keymap -s '^[{{ key_rh_up    }}' '^[[A'
#   bindkey -M $keymap -s '^[{{ key_rh_right }}' '^[[C'
# done
#
# # Get out of insert/visual mode with Alt-space (mapping to Esc)
# bindkey -s '^[ ' '\e'

# History backwards search (supports globbing)
# TODO : probably made obsolete by atuin
bindkey '^[g' history-incremental-pattern-search-backward

# Explicit atuin key bindings
bindkey '^r' _atuin_search_widget
bindkey '^[[A' _atuin_up_search_widget
bindkey '^[OA' _atuin_up_search_widget

### End key mappings ###

### Begin extra manual completions

# use generic completion system for programs not yet defined; (_gnu_generic works
# with commands that provide a --help option with "standard" gnu-like output.)
for compcom in cp deborphan df feh fetchipac gpasswd head hnb ipacsum mv pal stow uname ; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom

# bash compatibility
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
complete -o nospace -C /usr/bin/packer packer
# AWS cli packaging is shit
complete -C '/usr/local/bin/aws_completer' aws

### End extra manual completions

### Begin lazy loaded modules and completions ###

# We lazy-load these because they take WAY too long to load otherwise.
# See https://blog.jonlu.ca/posts/speeding-up-zsh and all the links at the bottom of the post

# NB : We migrated from nvm to Volta, which uses a shim approach, and therefore doesn't need any setup at shell startup time (besides modifying $PATH)
#
# # Lazily load nvm and its completion if installed
# # NB : This unloads nvm when re-sourcing .zshrc. Don't care.
# # It is possible to load it even on commands such as npm, grunt, etc...
# # with https://github.com/robbyrussell/oh-my-zsh/issues/5327#issuecomment-386480914
# # TODO : switch to a zsh_fpath file ?
# export NVM_DIR="$HOME/.nvm"
# if [[ -d $NVM_DIR ]]; then
#   nvm() {
#     echo "GLOBALRC : Loading nvm..."
#     source "$NVM_DIR/nvm.sh"  # This loads nvm
#     source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#     nvm $@ # Execute the newly defined nvm
#   }
# fi

### End lazy loaded modules and completions ###
