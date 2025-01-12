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

  outputs =
    inputs@{ self
    , nix-darwin
    , nixpkgs
    , nix-homebrew
    , home-manager
    , ...
    }:
    let
      # user = builtins.getEnv "USER";
      user = "drew";
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:

        nixpkgs.config.allowUnfree = true;
        # $ nix-env -qaP | grep wget

        environment.systemPackages =
          [
            # still missing python and node
            pkgs.neovim # working
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
            pkgs.jq # working
            pkgs.curl # working
            pkgs.wget # working
            pkgs.awscli2 # working
            pkgs.google-cloud-sdk

            pkgs.rustup # requires activation script
            pkgs.wezterm # working, cant test in vm
            pkgs.terraform # working
            pkgs.tmux # working
            pkgs.docker-compose # working
            pkgs.docker # working

            pkgs.slack # all but aarch64 linux
            pkgs.brave
            pkgs.telegram-desktop

            pkgs.spotify # all but aarch64 linux
            pkgs.discord # all but aarch64 linux
            pkgs.postman
            # pkgs.obs-studio # linux only

            # pkgs.bitwarden-desktop # linux only
            # pkgs.whatsapp-for-mac # macos only
            pkgs.google-chrome # all but aarch64 linux
            pkgs.utm # darwin only
            pkgs.mkalias # darwin only

            pkgs.ripgrep #  working
            pkgs.virtualenv # working
            pkgs.protobuf # not working
            pkgs.gnutar #  working
            pkgs.colima #  working darwin only
            pkgs.pre-commit # not working
            pkgs.poetry # not working
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

      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      # darwinConfigurations."CO000KDGTHHKWXK" = nix-darwin.lib.darwinSystem {



      darwinConfigurations."drews-Virtual-Machine" = nixpkgs.lib.genAttrs darwinSystems (system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          # specialArgs = inputs;
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
            home-manager.darwinModules.home-manager
            {
              home-manager.users.drew = {
                home.stateVersion = "23.05";
                home.username = user;
                home.homeDirectory = "/Users/${user}";
                programs.home-manager.enable = true;
              };
              users.users.${user} = {
                # isNormalUser = true;
                home = "/Users/${user}";
                # extraGroups = [ "wheel" ];
              };
            }
            ./hosts/darwin
          ];
        }
      );

      # darwinConfigurations."drews-Virtual-Machine" = nix-darwin.lib.darwinSystem {
      #   # specialArgs = { user };
      #   # specialArgs = inputs;
      #   modules = [
      #     configuration
      #     nix-homebrew.darwinModules.nix-homebrew
      #     {
      #       nix-homebrew = {
      #         enable = true;
      #         enableRosetta = true;
      #         inherit user;
      #         autoMigrate = true;
      #       };
      #     }
      #     home-manager.darwinModules.home-manager
      #     {
      #       home-manager.users.drew = {
      #         home.stateVersion = "23.05";
      #         home.username = user;
      #         home.homeDirectory = "/Users/${user}";
      #         programs.home-manager.enable = true;
      #       };
      #       users.users.${user} = {
      #         # isNormalUser = true;
      #         home = "/Users/${user}";
      #         # extraGroups = [ "wheel" ];
      #       };
      #     }
      #     ./hosts/darwin
      #   ];
      # };

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
