{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    let

      config = {
        owner = "drew";
        permissions = "0755";
      };
    in
    {
      home.file."dev".recursive = true;
      home.file."work".directory = config;
    };
}
