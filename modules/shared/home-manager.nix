{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    {
      home.stateVersion = "23.05";
      home.username = "drew";
      home.homeDirectory = "/Users/${"drew"}";
      programs.home-manager.enable = true;
      home.file = import ./symlink.nix { inherit config; };
      home.activation = import ./scripts.nix { inherit pkgs; };
    };
}
