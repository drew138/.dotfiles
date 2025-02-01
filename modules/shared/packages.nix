{ system, pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = import ./packages/${system}.nix {
    inherit pkgs;
  };

}
