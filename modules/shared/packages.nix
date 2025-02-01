{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = import ./packages/${builtins.currentSystem}.nix {
    inherit pkgs;
  };

}
