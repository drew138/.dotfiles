{ pkgs, config, ... }: {

  system.activationScripts = {
    # languages.text = pkgs.lib.mkForce ''
    #   echo "Setting up Python with pyenv..." >&2
    #
    #   export PYENV_ROOT="$HOME/.pyenv"
    #   export PATH="$PYENV_ROOT/bin:$PATH"
    #   eval "$(${pkgs.pyenv}/bin/pyenv init --path)"
    #
    #   # Get latest Python 3 version
    #   version=$(${pkgs.pyenv}/bin/pyenv install --list | grep " 3\.[0-9]\+.[0-9]\+$" | tail -1 | tr -d ' ')
    #
    #   if [[ -z "$version" ]]; then
    #     echo "Failed to determine the latest Python version." >&2
    #     exit 1
    #   fi
    #
    #   echo "Installing Python $version..." >&2
    #   ${pkgs.pyenv}/bin/pyenv install --skip-existing "$version"
    #   ${pkgs.pyenv}/bin/pyenv global "$version"
    #
    #   echo "Python $(python --version) is now active."
    # '';

    script.text = ''
      # Set up idk.
      echo "Setting up Python with pyenv..." >&2
      touch ~/.dotfiles/idk

    '';

    applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      # pkgs.lib.mkForce ''
      ''
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
  };
}

