{ config, pkgs, hostSpecificVars, lib, ... }:

{
  programs.vim = {
    enable = true;

    # This defaults to installing vim-full, which we need for the wayland_clipboard option
    # packageConfigurable =

    # TODO: We may want to switch to this, instead of setting $EDITOR ourselves
    # defaultEditor = false

    # TODO: We should eventually move the rest of the configuration here, especially plugin install
    # TODO: Variabilize path
    extraConfig = ''
      " Loading global vim configuration
      source /home/toadjaune/.globalrc/vim/vimrc
    '';
  };

}
