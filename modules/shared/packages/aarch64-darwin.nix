{ pkgs }:
let
  # still missing python and node
  cli = [
    pkgs.bat # working
    pkgs.fd # working
    pkgs.ripgrep #  working
    pkgs.fzf # working
    pkgs.gh # working
    pkgs.git # working
    pkgs.htop # working
    pkgs.jq # working
    pkgs.curl # working
    pkgs.wget # working
    pkgs.awscli2 # working
    pkgs.google-cloud-sdk
    pkgs.kubectl # working
    pkgs.terraform # working
    pkgs.tmux # working
    pkgs.gnutar #  working
    pkgs.colima #  working darwin only
    pkgs.docker # working
    pkgs.docker-compose # working
    pkgs.protobuf # not working
    pkgs.mkalias # darwin only
    pkgs.neovim # working
    pkgs.pre-commit # not working
    # pkgs.libgcc # not working
  ];

  packageManagers = [
    pkgs.uv # working
    pkgs.virtualenv # working
    pkgs.poetry #  working
  ];

  languages = [
    pkgs.pyenv # working
    pkgs.fnm # working (node version manager)
    pkgs.go # working
    pkgs.rustup # requires activation script
  ];

  apps = [
    pkgs.wezterm # working, cant test in vm
    pkgs.spotify # all but aarch64 linux
    pkgs.discord # all but aarch64 linux
    pkgs.postman
    pkgs.whatsapp-for-mac # macos only
    pkgs.google-chrome # all but aarch64 linux
    pkgs.utm # darwin only
    pkgs.brave
    pkgs.telegram-desktop
    pkgs.slack # all but aarch64 linux
  ];
in
cli ++ packageManagers ++ languages ++ apps
