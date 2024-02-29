{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "toadjaune";
  home.homeDirectory = "/home/toadjaune";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/toadjaune/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  programs.git = {
    enable = true;
    aliases = {
      # This pretty format is equivalent to --oneline --decorate, with the addition of commiter name and date
      # See https://stackoverflow.com/questions/5889878/color-in-git-log#16844346
      # and https://git-scm.com/docs/pretty-formats
      fullog = "log --graph --all --date-order --pretty=tformat:'%C(auto)%h%d %s %Cgreen(%cr) %Cblue<%an>'";
    };
    extraConfig = {

      # Global git config file

      # Good reference for "classic" options :
      # https://jvns.ca/blog/2024/02/16/popular-git-config-options/

      # [user]
      #   name = {{ git_user_name }}
      #   email = {{ git_user_email }}

      # Only push the current branch
      push.default = "upstream";

      # Don't need to specify --set-upstream when pushing a new branch
      push.autoSetupRemote = true;

      # Abort pulling if local and remote have diverged
      pull.ff = "only";

      # Repair files with Windows-endline-formatting-style (CRLF) on commit :
      core.autocrlf = "input";

      merge.tool = "vimdiff";

      # https://ductile.systems/zdiff3/
      merge.conflictstyle = "zdiff3";

      rerere.enabled = true;

      # cf https://difftastic.wilfred.me.uk/git.html
      # TODO : automatically install difftastic
      # TODO : switch to native home-manager difftastic setup ?
      diff.external = "difft";

      # https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
      # NB : This is likely useless when using difftastic
      diff.algorithm = "histogram";

      # Git, please, just stop dropping files in my working directory whenever I run `git mergetool`
      mergetool.keepbackup = false;
      # Thank you

      # Use https://github.com/dandavison/delta as pager
      # I'm not sure whether this is redundant with difftastic or not
      # TODO : switch to native home-manager delta setup ?
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;    # use n and N to move between diff sections
      diff.colorMoved = "default";

      commit.verbose = true;

      # https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
      # For now, I'll experiment with explicit --update-refs on the cli, to decide whether I want it to be enabled by default or not
      # rebase.updateRefs = true;

      # Detect corruption eagerly, this should not be needed but if it ever is, we'll be very happy to have enabled it
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckObjects = true;

      # More sensible submodule-related behavior
      status.submoduleSummary = true;
      diff.submodule = "log";
      submodule.recurse = true;

      # Sort branches and tags by latest activity instead of alphabetically
      branch.sort = "-committerdate";
      tag.sort = "taggerdate";

      # automatically clean up obsolete remote-tracking branches and tags
      fetch.prune = true;
      fetch.prunetags = true;

      # Format dates in git log as iso
      log.date = "iso";

      # Include private configuration
      include.path = "gitconfig.private";
    };

  };
}
