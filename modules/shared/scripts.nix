{ pkgs, ... }: {
  createFiles = ''
    echo "Creating .workrc.zsh" >&2
    touch ~/.workrc.zsh

    echo "Creating .workrc.gitconfig" >&2
    touch ~/.workrc.gitconfig
  '';
  createDirectories = ''
    echo "Creating dev directory" >&2
    mkdir -p ~/dev

    echo "Creating work directory" >&2
    mkdir -p ~/work
  '';

  installPython = ''
    echo "Setting up Python with pyenv..." >&2

    # Get latest Python 3 version
    export PATH="/usr/bin:/opt/homebrew/bin:$PATH"
    version=$(${pkgs.pyenv}/bin/pyenv install --list | grep " 3\.[0-9]\+.[0-9]\+$" | tail -1 | tr -d ' ')

    if [[ -z "$version" ]]; then
      echo "Failed to determine the latest Python version." >&2
      exit 1
    fi

    echo "Installing Python $version..." >&2
    ${pkgs.pyenv}/bin/pyenv install --skip-existing "$version"
    ${pkgs.pyenv}/bin/pyenv global "$version"

    echo "Python $(${pkgs.pyenv}/bin/pyenv version) is now active." >&2
  '';

  # installNode = ''
  #   echo "Setting up Node with fnm..." >&2
  #
  #   eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
  #
  #   # version=$(${pkgs.fnm}/bin/fnm ls-remote --lts | tail -n 1 | /usr/bin/awk '{print $1}')
  #   version=18.20.7
  #
  #   ${pkgs.fnm}/bin/fnm install $version
  #   ${pkgs.fnm}/bin/fnm use $version
  #   ${pkgs.fnm}/bin/fnm default $version
  #   echo $(${pkgs.fnm}/bin/fnm list) >&2
  # '';

  installRust = ''
    echo "Setting up Rust with rustup..." >&2
    ${pkgs.rustup}/bin/rustup update stable
  '';

  installTmuxPlugins = ''
    echo "Installing Tmux plugins..." >&2
    # Define the TPM directory
    export PATH="/run/current-system/sw/bin:$PATH"
    export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
    TPM_DIR="$HOME/.tmux/plugins/tpm"

    # Ensure the parent directory exists
    mkdir -p "$HOME/.tmux/plugins"

    # Clone the TPM repository if it doesn't exist, otherwise update it
    if [ -d "$TPM_DIR/.git" ]; then
        git -C "$TPM_DIR" pull
    else
        git clone --depth=1 https://github.com/tmux-plugins/tpm.git "$TPM_DIR"
    fi
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
  '';
}
