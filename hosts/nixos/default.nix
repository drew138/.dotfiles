{ config, pkgs, ... }: {
  imports = [
    ../../modules/nixos/desktop.nix
    ../../modules/shared/file.nix
    ../../modules/shared/directory.nix
    ../../modules/shared/symlink.nix
  ];
}
