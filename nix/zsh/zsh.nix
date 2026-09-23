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

    # Example syntax
    # plugins =
    #   {
    #     # will source zsh-autosuggestions.plugin.zsh
    #     name = "zsh-autosuggestions";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-autosuggestions";
    #       rev = "v0.4.0";
    #       sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
    #     };
    #   }
    # ];


    # initContent is the primary way to control the contents of .zshrc, the configuration below will get interleaved with generated configuration from nix options
    initContent = let

    # We rely on a separate template file because :
    # * This allows proper syntax highlighting when editing it
    # * It eliminates any escaping collision hell between complex zsh syntax and home-manager string templating
    atuin_widget_definitions = pkgs.stdenv.mkDerivation {
      name = "atuin_widget_definitions";
      # HOME is set to a non-existing path by default (/homeless-shelter), but even this command attempts to generate a config file in $HOME/.config/atuin
      # So, we set home to the build temp dir, so that the command doesn't fail, even if the generated config file is useless.
      buildCommand = "HOME=$TMPDIR ${lib.getExe pkgs.atuin} init zsh --disable-ctrl-r --disable-up-arrow --disable-ai > $out";
    };

    zshConfig100 = lib.mkOrder 100 ''
      ### begin home-manager VERY early config (lib.mkOrder 100) ###

      ${lib.fileContents ./zshrc-100.zsh}

      ### end home-manager VERY early config (lib.mkOrder 100) ###
    '';

    zshConfig500 = lib.mkBefore ''
      ### begin home-manager early config (lib.mkBefore / 500) ###

      # Define atuin widgets (but don't bind them, we do this manually)
      source ${ atuin_widget_definitions }

      ${lib.fileContents ./zshrc-500.zsh}

      ### end home-manager early config (lib.mkBefore / 500) ###
    '';

    # Use priority 550 to run stuff right before compinit (if we switch to using the generated compinit)
    zshConfig1000 = ''
      ### begin home-manager primary config (default / 1000) ###
      ### end home-manager primary config (default / 1000) ###
    '';

    in lib.mkMerge [ zshConfig100 zshConfig500 zshConfig1000 ];
  };

}
