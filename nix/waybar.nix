{ config, pkgs, hostSpecificVars, lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # TODO: waybar is still configured by ansible

}
