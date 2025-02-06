{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }@args:
    {
      home.file = import ./symlink.nix { config = args.config; };
      home.activation = import ./scripts.nix { pkgs = args.pkgs; };
    };
}
