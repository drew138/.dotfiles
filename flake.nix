{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
    let
      user = builtins.getEnv "USER";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:

        nixpkgs.config.allowUnfree = true;
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            # still missing python and node
            pkgs.neovim # working
            pkgs.mkalias # working
            pkgs.bat # working
            pkgs.fd # working
            pkgs.fzf # working
            pkgs.gh # working
            pkgs.git # working
            pkgs.go # working
            pkgs.kubectl # working
            pkgs.pyenv # working
            pkgs.fnm # working (node version manager)
            pkgs.uv # working
            pkgs.htop # working
            pkgs.jqa # working
            pkgs.curl # working
            pkgs.wget # working
            pkgs.awscli2 # working
            pkgs.google-cloud-sdk-gce

            pkgs.rustup # requires activation script
            pkgs.wezterm # working, cant test in vm
            pkgs.terraform # working
            pkgs.tmux # working
            pkgs.docker-compose # working
            pkgs.docker # working

            pkgs.slack
            pkgs.brave
            pkgs.telegram-desktop

            pkgs.spotify
            pkgs.discord
            pkgs.postman
            pkgs.obs-studio

            pkgs.bitwarden-desktop
            pkgs.whatsapp-for-mac
            pkgs.google-chrome
            pkgs.utm

            pkgs.ripgrep # not working
            pkgs.virtualenv # not working
            pkgs.protobuf # not working
            pkgs.gnutar # not working
            pkgs.pre-commit # not working
            pkgs.poetry # not working
            pkgs.colima # not working
            pkgs.libgcc # not working

          ];

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        programs.zsh.enable = true;

        fonts.packages = [
          # (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
          (pkgs.nerd-fonts.jetbrains-mono) # uncomment after version 2.25
        ];
        nixpkgs.hostPlatform = "aarch64-darwin";

        system.activationScripts.applications.text =
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


      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      # darwinConfigurations."CO000KDGTHHKWXK" = nix-darwin.lib.darwinSystem {
      darwinConfigurations."drews-Virtual-Machine" = nix-darwin.lib.darwinSystem {
        # specialArgs = { user };
        specialArgs = inputs;
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              inherit user;
              autoMigrate = true;
            };
          }
          ./hosts/darwin
        ];
      };

      darwinPackages = self.darwinConfigurations."drews-Virtual-Machine".pkgs;

      # nixosConfigurations = {
      #   specialArgs = [ user ];
      #   modules = [
      #     ./hosts/nixos
      #   ];
      # };
    };
}

# nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles#CO000KDGTHHKWXK
# darwin-rebuild switch --flake ~/.dotfiles#CO000KDGTHHKWXK
# how to set default browser
# add home to finder
