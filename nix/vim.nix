{ config, pkgs, hostSpecificVars, lib, ... }:

{
  programs.vim = {
    enable = true;

    # This defaults to installing vim-full, which we need for the wayland_clipboard option
    # packageConfigurable =

    # TODO: We may want to switch to this, instead of setting $EDITOR ourselves
    # defaultEditor = false

    # TODO: Migrate the rest of the plugins here
    plugins = [
      # Default value of home-manager, and also shipped by default on debian, etc
      pkgs.vimPlugins.vim-sensible
    ];

    # TODO: Variabilize path
    extraConfig = ''
      " Loading global vim configuration
      source /home/toadjaune/.globalrc/vim/vimrc
    '';
  };

}
