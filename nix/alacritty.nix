{ config, pkgs, lib, ... }:

{
  # GPU-accelerated terminal emulator
  # https://github.com/alacritty/alacritty/
  programs.alacritty = {
    enable = true;

    settings = {};
  };

}
