{ config, pkgs, hostSpecificVars, ... }:

{
  programs.firefox = {
    enable = true;

    # cf https://firefox-admin-docs.mozilla.org/reference/policies/extensionsettings/
    policies = {
      # Configuring extensions with firefox.profiles.default.extensions requires home-manager to have access to the extension file itself,
      # and they're not in home-manager. Someone put them in nur, but I'd rather not rely on nur for such critical components.
      # Instead, we define a firefox policy that automatically installs them from addons.mozilla.com
      # This works fine, but is global and doesn't allow per-profile extension configuration, so, we use normal_installed installation mode
      # so that extensions can be disabled manually per profile if desired. And it's more convenient to have the option anyway.
      #
      # To obtain an extension ID, navigate to an extension's listing page on https://addons.mozilla.org, and click Copy add-on ID in the "More information" section.

      ExtensionSettings = {
        "treestyletab@piro.sakura.ne.jp" = {
          installation_mode = "normal_installed";
          private_browsing = true;
        };
      };

    };

    # NB: The firefox executable installed by home-manager seems to reliably use the "default" profile, while the one installed by fedora uses
    #     the "default-release" one, while the two use the same firefox config dir, which is unexpected to me but certainly convenient for migration.

    # profiles.default.extensions.settings = {
    #   "uBlock0@raymondhill.net" = {
    #     force = true;
    #     settings = {
    #       selectedFilterLists = [
    #         "ublock-filters"
    #         "ublock-badware"
    #         "ublock-privacy"
    #         "ublock-unbreak"
    #         "ublock-quick-fixes"
    #       ];
    #     };
    #   };
    # };

  };
}
