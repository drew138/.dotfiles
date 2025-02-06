{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    {
      home.file = import ./symlink.nix {
        inherit config;
      };
      home.activation = import ./scripts.nix {
        inherit pkgs;
      };
    };
}
