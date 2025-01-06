{ ... }: {
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/desktop.nix
    ../../modules/shared/file.nix
    ../../modules/shared/directory.nix
    ../../modules/shared/symlink.nix
  ];
}
