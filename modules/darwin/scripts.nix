{ pkgs, config, ... }: {

  system.activationScripts = {
    applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';


    setup-python.text = pkgs.lib.mkForce ''
      echo settings up python...
      version=$(${pkgs.mkalias}/bin/pyenv install --list | grep " 3\.[0-9]\+.[0-9]\+$" | tail -1)
      ${pkgs.mkalias}/bin/pyenv install $version
      ${pkgs.mkalias}/bin/pyenv global $version
    '';

  };
}

