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
    pkgs.docker # working
    pkgs.docker-compose # working
    pkgs.protobuf # not working
    pkgs.neovim # working
    pkgs.pre-commit # working
    # pkgs.libgcc # not working
  ];

  packageManagers = [
    pkgs.uv # working
    pkgs.virtualenv # working
    pkgs.poetry # working
  ];

  languages = [
    pkgs.pyenv # working
    pkgs.fnm # working (node version manager)
    pkgs.go # working
    pkgs.rustup # requires activation script
  ];

  apps = [
    pkgs.wezterm # working, cant test in vm
    pkgs.postman
    pkgs.brave
    pkgs.telegram-desktop
    pkgs.obs-studio # linux only
    pkgs.bitwarden-desktop # linux only
  ];
in
cli ++ packageManagers ++ languages ++ apps
