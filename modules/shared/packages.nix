{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = import ./packages/${pkgs.system}.nix {
    inherit pkgs;
  };

}
