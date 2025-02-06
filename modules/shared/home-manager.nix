{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    {
      home.file = import ./symlink.nix {
        config = config;
      };
      home.activation = import ./scripts.nix {
        pkgs = pkgs;
      };
    };
}
