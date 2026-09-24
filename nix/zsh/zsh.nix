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
    # plugins = [
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

    # See https://github.com/unixorn/awesome-zsh-plugins for zsh plugins

    # zsh-autosuggestions plugin
    # https://github.com/zsh-users/zsh-autosuggestions
    # Adds Fish-like history-based suggestions
    #
    # NB: There's some extra configuration in the main zshrc
    # NB: Plugin loading has priority 700
    autosuggestion.enable = true;

    # zsh-syntax-highlighting plugin
    # https://github.com/zsh-users/zsh-syntax-highlighting
    # Adds Fish-like syntax highlighting
    #
    # NB: Plugin loading has priority 1200
    #     Which makes sense because it needs to be loaded after compinit, and as late as possible, cf the project README
    syntaxHighlighting = {
      enable = true;
      highlighters = ["brackets"]; # NB: "main" is always included
      styles = {
        unknown-token         = "fg=red,bold";
        reserved-word         = "fg=yellow";
        alias                 = "fg=green,bold";
        builtin               = "fg=green,bold";
        function              = "fg=green,bold";
        command               = "fg=green,bold";
        precommand            = "fg=green";
        hashed-command        = "fg=green";
        path                  = "fg=blue,bold";
        path_prefix           = "fg=blue";
        path_approx           = "fg=blue,underlined";
        globbing              = "fg=yellow,underlined";
        single-hyphen-option  = "fg=purple,bold";
        double-hyphen-option  = "fg=purple,bold";
        back-quoted-argument  = "fg=purple,bold";
        default               = "fg=cyan,bold";
      };
    };

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

    # zsh-completions plugin
    # https://github.com/zsh-users/zsh-completions
    # Adds community-contributed completion scripts for various common utilities that don't natively ship with completion
    # As of 2026-09-23 with my setup, you can check that this is correctly loaded by looking whether uuidgen has a proper completion
    # Since we generally consider a program package to be responsible for providing its own completion, we only use this repository as a last-resort fallback, if no other completion was found.
    zsh_completions_plugin = pkgs.fetchFromGitHub {
      name = "plugin-zsh-completions";
      owner = "zsh-users";
      repo = "zsh-completions";
      rev = "0.36.0"; # released 2026-03-09
      sha256 = "sha256-XCSC7DyhfnxzKjtbdsu7/pyw8eoVLPdthEoFZ8rBAyo=";
    };

    in lib.mkMerge [
      # cf https://github.com/nix-community/home-manager/blob/master/modules/programs/zsh/default.nix for default priority values

      (lib.mkOrder 100 ''
        ### begin home-manager VERY early config (lib.mkOrder 100) ###

        ${lib.fileContents ./zshrc-100.zsh}

        ### end home-manager VERY early config (lib.mkOrder 100) ###
      '')

      (lib.mkBefore ''
        ### begin home-manager early config (lib.mkBefore / 500) ###

        # Define atuin widgets (but don't bind them, we do this manually)
        source ${ atuin_widget_definitions }

        ${lib.fileContents ./zshrc-500.zsh}

        ### end home-manager early config (lib.mkBefore / 500) ###
      '')

      # Priority 550 : recommended by the docs for configuration that specifically needs to run before compinit

      (lib.mkOrder 570 ''
        ### begin home-manager compinit (lib.mkOrder 570) ###

        # Load extra completions from zsh-completions plugin
        # Only add them as a last resort fallback (that's why we modify fpath immediately before compinit)
        fpath=($fpath ${zsh_completions_plugin}/src)

        # Priority 570 : actual compinit command, when managed by home-manager with completionInit.
        #                Which we currently don't, but we keep our own compinit declaration at the same priority so that any extra config that adds configuration with this assumption ends up in the right place.

        ${lib.fileContents ./zshrc-570.zsh}

        ### end home-manager compinit (lib.mkOrder 570) ###
      '')

      (''
        ### begin home-manager primary config (default / 1000) ###

        ${lib.fileContents ./zshrc-1000.zsh}

        ### end home-manager primary config (default / 1000) ###
      '')

    ];

  };

}
