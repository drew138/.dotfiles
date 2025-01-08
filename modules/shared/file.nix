{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    let
      config = {
        text = "";
        owner = "drew";
        permissions = "0755";
      };
    in
    {
      home.file.".workrc.zsh".create = config;
      home.file."workrc.gitconfig".create = config;
    };
}
