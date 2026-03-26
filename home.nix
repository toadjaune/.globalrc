{ config, pkgs, lib, ... }:

{
  imports = [
    ./nix/git.nix
    ./nix/hyprland.nix
    ./nix/sway.nix
    ./nix/tmux.nix
    ./nix/vim.nix
  ];

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

  programs.atuin = {
    enable = true;
    enableBashIntegration = false; # don't use atuin with bash
    enableZshIntegration  = false; # use atuin with zsh, but manually manage the widget
    settings = {
      # documentation : https://docs.atuin.sh/configuration/config/

      # Updates are managed via home-manager
      update_check = false;

      # We don't ever want history sync
      auto_sync = false;

      # Don't require an extra enter press for running the command
      # This will probably become the default at some point in the future
      enter_accept = true;

      # When using the up arrow, don't mix history between shells
      filter_mode_shell_up_key_binding = "session";

      style = "full"; # looks better
      # keymap_mode = "vim-insert"; # TODO : test some more
    };

  };

  # TODO : see if programs.eza.enableZshIntegration is equivalent / better than our manual alias
  programs.eza.enable = true;

  programs.zed-editor = {
    enable = true;
    # The binary installed by home-manager is `zeditor`, whereas the one installed with the official install command is `zed`
    # As of 2026-03-20, the version installed by home-manager doesn't even open a window. It's not a zed version issue, I tried installing the exact same version with :
    # curl -f https://zed.dev/install.sh | ZED_VERSION=<same version as home-manager> sh
    # There's not much point in doing that anyway, it auto-updates anyway.
    # For now, let's test it that way and we'll see if we can fix it later.
    # Also, even though we're invoking the "wrong" binary, the configuration below (extensions, etc) is still effective.
    # package =

    extensions = [
      "terraform"
    ];

    # Those settings end up in ~/.config/zed/settings.json
    # This file is normally mutable at runtime by zed, through UI.
    # Setting this to false does not prevent making configuration changes through the zed UI, they just won't be persisted.
    # You may want to temporarily switch this to true for experimenting with new settings that are easy to set from the UI, but whose config syntax is hard to understand.
    # The list of options below looks pretty well-documented though, so, this should be fine.
    mutableUserSettings = false;
    # home-manager is very good at dealing with the config file being mutable, notably :
    # * home-manager will properly merge existing settings present in the file with the ones specified here
    #   * including recursively, for configurations with deep structures
    # * it will overwrite any parameter with a value different from what is configured here
    # * ... but not touch any unmanaged config option (probably set through the zed UI)
    #
    # You need to restart zed for external changes to the file to be taken into account (there's no auto-reload, and no action to reload configuration from file)
    # https://zed.dev/docs/reference/all-settings
    userSettings = {
      disable_ai = true; # Globally disable all AI features
      vim_mode = true;
      theme = {
        mode = "system"; # rely on the global system theme, probably via XDG portal
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
    };

  };
}
