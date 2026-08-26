{ pkgs, lib, ... }:

{
  imports = [
    ./nix/alacritty.nix
    ./nix/git.nix
    ./nix/hyprland.nix
    ./nix/sway.nix
    ./nix/tmux.nix
    ./nix/vim.nix
    ./nix/waybar.nix
    ./nix/zed.nix
    ./nix/zsh.nix

    # ./nix/uv-manual-install.nix
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
  home.stateVersion = "26.05"; # Please read the comment before changing.

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

    pkgs.deno   # yt-dlp requires it for js challenges and so
    pkgs.yt-dlp # download videos from youtube

    pkgs.vimv   # mass-renaming tool

    # fonts
    pkgs.nerd-fonts.fira-code # nerd-fonts patched FiraCode font, for terminals. Basic reliable font, made by Mozilla.
    pkgs.monaspace            # very cool monospace fonts with texture healing, and several styles. Not great for terminal, as the icons are smaller, but may be good for IDE ? https://monaspace.githubnext.com/
    pkgs.nerd-fonts.monaspace # Same, with nerdfonts glyph patch

    # OpenGL programs tend to be broken when installed through home-manager, and need nixGL as a wrapper:
    # * https://github.com/alacritty/alacritty/issues/7631
    # * https://github.com/nix-community/home-manager/issues/2251
    # * https://github.com/nix-community/nixGL
    # Although we prefer to wrap the corresponding directly directly in the home-manager config, having the wrapper binary available can be useful.
    pkgs.nixgl.nixGLIntel # mesa-based OpenGL Wrapper
  ];

  # NB: This is actually required ; without it, fonts are only exposed in ~/.nix-profile/share/fonts/, which is
  #     not sufficient for graphical applications not started from shell to find them.
  #     It does make them appear twice in `fc-list` though (once directly from the nix store, once from the path above)
  fonts.fontconfig.enable = true;

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

  # Python version/package manager
  # NB: home-manager/nixos does not seem to offer a way to install shell completions itself, we do it with ansible
  programs.uv.enable = true;

  # Temporary workaround, we need uv version at least 0.12.6
  # Finding the correct way to override the version and have nix compile it transparently is easy, but finding the correct syntax for that was a purge.
  # Docs:
  # * Documentation with the syntax that ended up working : https://discourse.nixos.org/t/overriding-version-cant-find-new-cargohash/31502/6
  # * It should be possible to use pkgs.uv.override instead, but I couldn't make it work : https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/9
  # * https://github.com/allrealmsoflife/nix-hour-transcripts/blob/6536aae0c9bd5b944a87f7cb47f60266cfd5cc2d/episodes/5/5.md
  programs.uv.package = pkgs.uv.overrideAttrs (drv: rec {
    version = "0.12.6";

    src = pkgs.fetchFromGitHub {
      owner = "astral-sh";
      repo = "uv";
      tag = drv.version;
      hash = "sha256-qORoqipLvC9v4f5pKIKEaLumB7kwoWgwptLBjNkO614=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-A3bIy61Ca4ZknA4YNj6VwYEWbdKHO5KKQCfMkogv9HE=";
    };
  });

}
