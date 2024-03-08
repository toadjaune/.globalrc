# TODO : This is probably not the proper way to access lib functions
lib: {
  enable = true;

  # For configuration guides, see :
  # https://gist.github.com/snuggs/800936
  # https://wiki.archlinux.org/index.php/Tmux
  # https://gist.github.com/spicycode/1229612
  #
  # For the list of breaking changes and, and how to deal with them, see :
  # https://github.com/tmux/tmux/blob/master/CHANGES
  # https://stackoverflow.com/questions/35016458/how-to-write-if-statement-in-tmux-conf-to-set-different-options-for-different-t/40902312#40902312

  # Start numbering windows from 1 (0 key is too far away, and breaks my brain)
  baseIndex = 1;

  # More lines of scrollback history
  historyLimit = 10000;

  mouse = true;
  clock24 = true;

  keyMode = "vi";

  extraConfig = lib.strings.concatLines [

    # ENVIRONMENT COMPATIBILITY AND FEATURE ACTIVATION

    # Propagate the $TERM variable to child shells, for color and special glyphs
    # This is way cleaner than setting it from the shell startup files
    ''set -g default-terminal "$TERM"''

    # Allow support for true 24-bit colors
    # TODO : maybe we should only override this if $TERM contains "256color"
    # TODO : check if this is still required
    ''set -ga terminal-overrides ",xterm-256color:Tc"''

    # tmux is natively capable of sending data into the wayland clipboard
    # (as far as I understand, through an escape sequence, so, this works also because alacritty supports it on its end.
    # Still, it's good not to have to use wl-copy or anything, this feels way cleaner)
    # NB : tmux can write to the system clipboard, but not read from it. It does write anything you yank BOTH into the system clipboard
    # and into its own internal paste buffer, so it can still paste stuff you yanked internally.
    # All of this is the default behaviour, there's nothing to configure.
    # However, setting set-clipboard to "on" instead of "external" (the default) makes tmux _also_ accept clipboard write requests from the program inside it
    # (again, via escape sequences), and propagate it both into its own buffer and into the system clipboard.
    # We want that, for behavior consitency between when a program is run with and without tmux.
    ''set-option -g set-clipboard on''

    # Emulate scrolling by sending up and down keys if specific commands are running in the pane
    # https://superuser.com/questions/989505/pass-mouse-events-through-tmux
    ''tmux_commands_with_legacy_scroll="nano less more man git"''

    ''bind-key -T root WheelUpPane \
      if-shell -Ft= '#{?mouse_any_flag,1,#{pane_in_mode}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Up Up Up" "copy-mode -et="'
    ''

    ''bind-key -T root WheelDownPane \
      if-shell -Ft = '#{?pane_in_mode,1,#{mouse_any_flag}}' \
        'send -Mt=' \
        'if-shell -t= "#{?alternate_on,true,false} || echo \"#{tmux_commands_with_legacy_scroll}\" | grep -q \"#{pane_current_command}\"" \
          "send -t= Down Down Down" "send -Mt="'
    ''

    # reload tmux conf with C-b r
    # TODO : fix
    # bind-key r source-file "{{ ansible_user_dir }}/.tmux.conf"

    # Smart pane switching with awareness of Vim splits.
    # See: https://github.com/christoomey/vim-tmux-navigator
    # TODO : C-\ apparently refers to vim mapleader key, this should be configured
    # to the same at the ansible role scale
    # bind-key -n C-m if-shell "$is_vim" "send-keys C-m" "select-pane -l"
    # NB : C-m <=> Enter
    # bind-key -T copy-mode-vi C-m select-pane -l
    # The actual keybindings are defined in the relevant section of this file
    ''is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"''

    ### KEYBINDINGS ###

    # NB : We tried some trickery to use tmux (on a server, over ssh) inside tmux (locally)
    # without bindings conflicts, but it doesn't work very well, and is not all that useful to me
    # cf http://stahlke.org/dan/tmux-nested/
    # If I ever want to do somthing like this again, connecting a local tmux client to a remote server
    # is probably the way to go.

    # Use Alt-h and Alt-l to change tab
    ''bind-key -n M-h prev''
    ''bind-key -n M-l next''

    # Use Alt-f as default prefix key
    ''set-option -qg prefix M-f''
    # Workaround for Mac, as there's a signle layer for Alt and AltGr (move this to either a build-time or run-time check if using a mac again in the future)
    # set-option -qg prefix C-f

    # Movement across panes with awareness of vim splits
    ''
    bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
    bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
    bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -U"
    bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
    bind-key -T copy-mode-vi C-h select-pane -L
    bind-key -T copy-mode-vi C-j select-pane -D
    bind-key -T copy-mode-vi C-l select-pane -U
    bind-key -T copy-mode-vi C-l select-pane -R
    ''

    # Copy-paste bindings consistent with vim
    ''
    bind-key P paste-buffer
    bind-key -T copy-mode-vi v    send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v  send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y    send-keys -X copy-pipe-and-cancel
    ''

    ### STYLING ###

    # Change the default status bar color, to immediately know whether our configuration is loaded or not
    ''set -g status-bg blue''
  ];
}

