{ config, pkgs, hostSpecificVars, lib, ... }:

{
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
