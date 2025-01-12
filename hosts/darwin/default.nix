{ ... }: {
  imports = [
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/desktop.nix
    ../../modules/darwin/scripts.nix
    #../../modules/shared/file.nix
    #../../modules/shared/directory.nix
    ../../modules/shared/symlink.nix
  ];
}
