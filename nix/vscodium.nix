{ pkgs, ... }:

# VSCodium is a community re-packaging of the VSCode open-source codebase, without the Microsoft telemetry.
#
# NB:
# * As of 2026-11-05: We're not really using it anymore, but we're still migrating it to clear it from ansible config, and remove a system-wide erroring 3rd-party repository
# * home-manager/nixos also has vscode packaged, not sure how they deal with the whole telemetry and possibly closed-source aspect

{
  # home.packages = [
  #   # nix language servers
  #   pkgs.nil
  #   pkgs.nixd
  # ];

  programs.neovim.enable = true; # used in vscodium through an extension

  programs.vscodium = {
    enable = true;

    # This configures the default vscode profile. It's possible to make a dedicated one as well, but we don't have a way to select it specifically. So, we directly modifiy the default one instead.
    profiles.default = {
      # VSCodium pulls its extensions from OpenVSX instead of the VSCode app store
      # This means some extensions may be absent, or not the exact same version
      # Details : https://github.com/VSCodium/vscodium/issues/448
      # Procedure to make an extension available on open-vsx : https://github.com/VSCodium/vscodium/blob/master/DOCS.md#extensions-marketplace
      # Manually install an extension from the marketplace : https://milicendev.netlify.app/article/install-vs-codium-and-integrate-vs-code-extensions/
      #
      # Ideally (as below), we prefer to not even care about this, and install extensions directly from nix
      extensions = [
        pkgs.vscode-extensions.asvetliakov.vscode-neovim # neovim install
        pkgs.vscode-extensions.oderwat.indent-rainbow # more readable indent
        pkgs.vscode-extensions.editorconfig.editorconfig # read repo-local .editorconfig
        pkgs.vscode-extensions.eamodio.gitlens # nice git blame integration
        pkgs.vscode-extensions.redhat.vscode-yaml # yaml
        pkgs.vscode-extensions.tamasfe.even-better-toml # toml
        pkgs.vscode-extensions.hashicorp.terraform # terraform formatting/auto-completion
        # python
        pkgs.vscode-extensions.ms-python.python
        # - ms-python.black
      ];

      # cf https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
      # Those settings get rendered to ~/.config/VSCodium/User/settings.json, and home-manager makes vscodium reload its configuration
      userSettings =
      {
        "window.zoomLevel"= 1;

        # Run neovim in a separate process
        # cf https://github.com/vscode-neovim/vscode-neovim#installation
        "extensions.experimental.affinity"= {
          "asvetliakov.vscode-neovim"= 1;
        };

        # Use a patched font for terminal, notably for powerlevel10k
        # https://code.visualstudio.com/docs/terminal/appearance
        "terminal.integrated.fontFamily"= "FiraCode Nerd Font";

        # Follow system light/dark theme (org.freedesktop.appearance.color-scheme)
        # https://code.visualstudio.com/docs/getstarted/themes#_auto-switch-based-on-os-color-scheme
        # NB : It's still possible to customize separately light and dark theme
        "window.autoDetectColorScheme"= true;

        # Sync open tabs with currently checked-out branch
        "scm.workingSets.enabled"= true;

        # When saving files; automatically reformat them with configured formatter
        "editor.formatOnSave"= true;

        # Replace text on the minimap with rectangles of the same shape. More legible.
        "editor.minimap.renderCharacters"= false;

        # Lanquage-specific configurations
        #"[terraform]": {
        #  "editor.defaultFormatter": "hashicorp.terraform";
        #  "editor.formatOnSave": false;
        #  "editor.codeActionsOnSave": {
        #    "source.formatAll.terraform": true
        #  };
        #},
        #"[terraform-vars]": {
        #  "editor.defaultFormatter": "hashicorp.terraform";
        #  "editor.formatOnSave": false;
        #  "editor.codeActionsOnSave": {
        #    "source.formatAll.terraform": true
        #  };
        #};
        "[terraform]"= {
          "editor.defaultFormatter"= "hashicorp.terraform";
          "editor.formatOnSave"= true;
          "editor.formatOnSaveMode"= "file";
        };
        "[terraform-vars]"= {
          "editor.defaultFormatter"= "hashicorp.terraform";
          "editor.formatOnSave"= true;
          "editor.formatOnSaveMode"= "file";
        };
      };

    };

  };

}
