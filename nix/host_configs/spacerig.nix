{ ... }:

{
  home.packages = [];

  services.kanshi.settings = [

    {
      profile.name = "desktop";
      profile.outputs = [
        {
          criteria = "DP-1";
          status = "enable";
          position = "0,0";
        }
      ];
    }

  ];
}
