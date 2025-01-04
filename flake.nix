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
      configuration = { pkgs, config, ... }: {
        # List packages installed in system profile. To search by name, run:

        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            # still missing python and node
            pkgs.neovim
            pkgs.mkalias
            pkgs.bat
            pkgs.fd
            pkgs.fzf
            pkgs.gh
            pkgs.git
            pkgs.go
            pkgs.kubectl
            pkgs.pyenv
            pkgs.fnm # node version manager
            pkgs.uv
            pkgs.htop
            pkgs.jq
            pkgs.curl
            pkgs.wget
            pkgs.awscli2
            pkgs.google-cloud-sdk-gce

            pkgs.rustup
            pkgs.wezterm
            pkgs.terraform
            pkgs.tmux
            pkgs.docker-compose
            pkgs.docker

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

            pkgs.ripgrep
            pkgs.virtualenv
            pkgs.protobuf
            pkgs.gnutar
            pkgs.pre-commit
            pkgs.poetry
            pkgs.colima

            pkgs.libgcc

          ];

        homebrew = {
          enable = true;
          # required by python for scikit
          # learn god knows why
          brews = [ "llvm" "libomp" ];

          casks = [ "notion" "notion-calendar" "dropbox" "background-music" ];
          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
        };

        nixpkgs.config.allowUnfree = true;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        programs.zsh.enable = true;

        fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
          # (pkgs.nerd-fonts.jetbrains-mono) # uncomment after version 2.25
        ];

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


        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        system.defaults = {
          dock = {
            autohide = true;
            launchanim = false;
            show-recents = false;
            tilesize = 36;
            persistent-apps = [
              "/Applications/System Settings.app"
              "${pkgs.postman}/Applications/Postman.app"
              "${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
              "${pkgs.wezterm}/Applications/WezTerm.app"
              "${pkgs.slack}/Applications/Slack.app"
              "${pkgs.google-chrome}/Applications/Google Chrome.app"
              "${pkgs.whatsapp-for-mac}/Applications/WhatsApp.app"
              "${pkgs.spotify}/Applications/Spotify.app"
              "${pkgs.discord}/Applications/Discord.app"
              "${pkgs.utm}/Applications/UTM.app"

            ];
          };
          finder.FXPreferredViewStyle = "Nlsv";
          loginWindow.GuestEnabled = false;
          NSGlobalDomain = {
            AppleICUForce24HourTime = true;
            AppleInterfaceStyle = "Dark";
            KeyRepeat = 2;
            InitialKeyRepeat = 15;

          };
          screencapture.location = "~/Pictures/Screenshots";
          screencapture.type = "png";
          trackpad.Clicking = true;
        };

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";



        # programs.hyprland = {
        #   enable = true;
        #   nvidiaPatches = true;
        #   xwayland.enable = true;
        # };
        #
        # environment.sessionVariables = {
        #   # If your cursor becomes invisible
        #   WLR_NO_HARDWARE_CURSORS = "1";
        #   # Hint electron apps to use wayland
        #   NIXOS_OZONE_WL = "1";
        # };
        #
        # hardware = {
        #   # Opengl
        #   opengl.enable = true;
        #
        #   # Most wayland compositors need this
        #   nvidia.modesetting.enable = true;
        # };

      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."CO000KDGTHHKWXK" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "drew";
              autoMigrate = true;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."CO000KDGTHHKWXK".pkgs;

      nixosConfigurations = { };
    };
}

# nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles#CO000KDGTHHKWXK
# darwin-rebuild switch --flake ~/.dotfiles#CO000KDGTHHKWXK
