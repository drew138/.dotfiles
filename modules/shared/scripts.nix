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

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(${pkgs.pyenv}/bin/pyenv init --path)"

    # Get latest Python 3 version
    version=$(${pkgs.pyenv}/bin/pyenv install --list | grep " 3\.[0-9]\+.[0-9]\+$" | tail -1 | tr -d ' ')

    if [[ -z "$version" ]]; then
      echo "Failed to determine the latest Python version." >&2
      exit 1
    fi

    echo "Installing Python $version..." >&2
    ${pkgs.pyenv}/bin/pyenv install --skip-existing "$version"
    ${pkgs.pyenv}/bin/pyenv global "$version"

    echo "Python $(python --version) is now active."
  '';

  installNode = ''
    echo "Setting up Node with fnm..." >&2

    eval "$(${pkgs.fnm}/bin/fnm env)"

    version=$(${pkgs.fnm}/bin/fnm ls-remote --lts | tail -n 1 | awk '{print $1}')

    ${pkgs.fnm}/bin/fnm install $version
    ${pkgs.fnm}/bin/fnm use $version
    ${pkgs.fnm}/bin/fnm default $(${pkgs.fnm}/bin/fnm current)
  '';
}
