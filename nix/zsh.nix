{ config, pkgs, lib, hostSpecificVars, ... }:

{
  # Modern ls replacement
  # https://github.com/eza-community/eza
  programs.eza = {
    enable = true;
    # TODO: This generates a bunch of aliases, see if they're OK or if we want to keep setting them ourselves
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;

    # Configuration fields with a default value, that we disable for now because those options are set in our ansible template
    completionInit = "";
    # dotDir = null; # unsure if it had any effect ?

    # Those settings cannot be nulled, so, we're configuring them here:

    # This sets :
    # HISTSIZE : Number of history commands to read at shell startup, and to keep per session
    # SAVEHIST : Number of history commands to write at shell exit
    # TODO: The default of 10000 is probably fine as well
    history.size = 1000;

    # NB: The pre-home-manager config was ~/.zsh_history, which is the same file but defined with a relative path.
    #     This _should_ be fine, but the previous file had a comment about sshrc, so, it needs to be tested, especially with a remote user path with a different home path
    #     And using a relative path in this home-manager option is explicitly deprecated
    # TODO: Test properly
    # history.path = "~/.zsh_history";

    # See https://zsh.sourceforge.io/Doc/Release/Options.html#History for options definition
    # NB: Most of those don't matter much, because we're using atuin now anyway ; it's only used for zsh-autosuggestions afaict
    # sets HIST_IGNORE_ALL_DUPS, which removes older instances of the same command from history
    history.ignoreAllDups = true;
    # sets HIST_IGNORE_DUPS. which is like HIST_IGNORE_ALL_DUPS but only with the previous command.
    # It's presumably not going to change anything, considering we're setting HIST_IGNORE_ALL_DUPS anyway, so, set it just in case.
    history.ignoreDups = true;
    # sets HIST_IGNORE_SPACE, which prevents a command starting with a space from being stored in history. Useful when manipulating secrets.
    history.ignoreSpace = true;
    # sets SHARE_HISTORY, which shares history between sessions, but only appends new commands to the shared history file at session end (?)
    history.share = true;
    # sets (NO_)APPEND_HISTORY, which should not be required because we're setting INC_APPEND_HISTORY_TIME
    history.append = false;
    # sets (NO_)EXTENDED_HISTORY, which stores timestamps with commands
    # TODO: We probably want to turn this on ?
    history.extended = false;
    # sets (NO_)HIST_EXPIRE_DUPS_FIRST, irrelevant since we're setting HIST_IGNORE_ALL_DUPS.
    history.expireDuplicatesFirst = false;
    # sets (NO_)HIST_FIND_NO_DUPS, irrelevant since we're setting HIST_IGNORE_ALL_DUPS.
    history.findNoDups = false;
    # sets (NO_)HIST_SAVE_NO_DUPS, irrelevant since we're setting HIST_IGNORE_ALL_DUPS.
    history.saveNoDups = false;
    # HIST_FCNTL_LOCK is always set, which probably makes sense on a modern system anyway

    # Some specific tasks need to be done before loading .zshrc
    # https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout#71258
    # http://zsh.sourceforge.net/Intro/intro_3.html
    # Currently, we need it only to run code before loading /etc/zsh/zshrc
    envExtra = ''
      # Disable compinit call in /etc/zsh/zshrc on ubuntu
      skip_global_compinit=1
    '';

    initContent = lib.mkBefore ''
      # Load legacy ansible-managed template as a transition mechanism
      . ${ config.home.homeDirectory }/.globalrc/files/zshrc
    '';
  };

}
