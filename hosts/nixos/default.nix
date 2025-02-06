{ pkgs, ... }: {
  imports = [
    ../../modules/nixos/desktop.nix
    ../../modules/shared/file.nix
    ../../modules/shared/directory.nix
    ../../modules/shared/symlink.nix
    ../../modules/shared/packages.nix
    ../../modules/shared/scripts.nix
  ];

  system.stateVersion = 5;
  nix.settings.experimental-features = "nix-command flakes";

  fonts.packages = [
    # (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    (pkgs.nerd-fonts.jetbrains-mono) # uncomment after version 2.25
  ];
}
