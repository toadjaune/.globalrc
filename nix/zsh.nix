{ config, pkgs, lib, hostSpecificVars, ... }:

{
  # Modern ls replacement
  # https://github.com/eza-community/eza
  programs.eza = {
    enable = true;
    # TODO: This generates a bunch of aliases, see if they're OK or if we want to keep setting them ourselves
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;

    # Configuration fields with a default value, that we disable for now because those options are set in our ansible template
    completionInit = "";
    # dotDir = null; # unsure if it had any effect ?
    # TODO: Complete the initial cleanup of default config before doing anything else

    # Those settings cannot be nulled, so, we're configuring them here:

    # This sets :
    # HISTSIZE : Number of history commands to read at shell startup, and to keep per session
    # SAVEHIST : Number of history commands to write at shell exit
    # TODO: The default of 10000 is probably fine as well
    history.size = 1000;

    # NB: The pre-home-manager config was ~/.zsh_history, which is the same file but defined with a relative path.
    #     This _should_ be fine, but the previous file had a comment about sshrc, so, it needs to be tested, especially with a remote user path with a different home path
    #     And using a relative path in this home-manager option is explicitly deprecated
    # TODO: Test properly
    # history.path = "~/.zsh_history";

    # Some specific tasks need to be done before loading .zshrc
    # https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout#71258
    # http://zsh.sourceforge.net/Intro/intro_3.html
    # Currently, we need it only to run code before loading /etc/zsh/zshrc
    envExtra = ''
      # Disable compinit call in /etc/zsh/zshrc on ubuntu
      skip_global_compinit=1
    '';

    initContent = lib.mkBefore ''
      # Load legacy ansible-managed template as a transition mechanism
      . ${ config.home.homeDirectory }/.globalrc/files/zshrc
    '';
  };

}
