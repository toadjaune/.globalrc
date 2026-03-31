{ config, pkgs, lib, ... }:

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

    # NB: It looks like the way the extensions management works is that :
    # * home-manager injects the extension list in the user configuration
    # * zed installs it at its next startup
    # Which implies that :
    # * extension versions are not pinned, and cannot be rolled back
    # * configuration mistakes cannot be detected at home-manager apply time
    # * we cannot remove an extension with home-manager
    # https://zed.dev/docs/extensions/installing-extensions
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

      # Globally disable all AI features. They can still be re-enabled individually if desired.
      disable_ai = true;

      # Global vim mode, that attempts to map zed interface semantics to vim-compatible, or at least vim-like keybindings
      vim_mode = true;

      theme = {
        mode = "system"; # rely on the global system theme, probably via XDG portal
        light = "Ayu Light";
        dark = "Ayu Dark";
      };

      # Missing features as of 2026-03-31:
      # * Minimap : https://github.com/zed-industries/zed/discussions/23957

      # Things that I need to investigate:
      # * Equivalent of vscode scm.workingSets.enabled (synchronize open tabs with currently checked-out branch
      #   * Doesn't seem supported by zed, and I haven't even found an issue
      #     * TODO: Open an issue
      #       * https://code.visualstudio.com/updates/v1_89#_saverestore-open-editors-when-switching-branches
      #       * https://github.com/microsoft/vscode/issues/35307

    };
  };

}
