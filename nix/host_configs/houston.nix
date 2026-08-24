{ lib, ... }:

{
  home.packages = [];

  programs.zsh.initContent = lib.mkAfter ''
    # By default, poetry will attempt to use the system keyring, even though it's not required
    # https://github.com/python-poetry/poetry/issues/8761
    export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
  '';


  services.kanshi.settings = [

    {
      profile.name = "laptop";
      profile.outputs = [
        {
          criteria = "eDP-1";
          status = "enable";
          position = "0,0";
        }
      ];
    }

    {
      # TODO: open an issue/PR, so that names are quoted in the resulting file
      # profile.name = "work external screen + laptop";
      profile.name = "work_external_screen_+_laptop";
      profile.outputs = [
        {
          criteria = "LG Electronics LG HDR 4K 0x00038472";
          status = "enable";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          status = "enable";
          position = "3840,280";
        }
      ];
    }

    {
      # profile.name = "home external screen + laptop";
      profile.name = "home_external_screen_+_laptop";
      profile.outputs = [
        {
          criteria = "Samsung Electric Company U32J59x H4ZMB00786";
          status = "enable";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          status = "enable";
          position = "3840,0";
        }
      ];
    }

    {
      # profile.name = "'dad external screen + laptop'";
      profile.name = "dad_external_screen_+_laptop";
      profile.outputs = [
        {
          criteria = "Philips Consumer Electronics Company PHL 245E1 0x00006106";
          status = "enable";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          status = "enable";
          position = "2560,0";
        }
      ];
    }

  ];
}
