{ self, pkgs, system, ... }: {
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/desktop.nix
    ../../modules/darwin/scripts.nix
    #../../modules/shared/file.nix
    ../../modules/shared/symlink.nix
    ../../modules/shared/directory.nix
    ../../modules/shared/packages.nix
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 5;

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = system;

  programs.zsh.enable = true;

  fonts.packages = [
    # (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    (pkgs.nerd-fonts.jetbrains-mono) # uncomment after version 2.25
  ];
}
