{ ... }: {
  homebrew = {
    enable = true;
    # required by python for scikit
    # learn god knows why
    brews = [
      "llvm" # required by python for scikit learn
      "libomp" # required by python for scikit learn
      "xz"
    ];
    casks = [
      "notion"
      "notion-calendar"
      "dropbox"
      "bitwarden"
      "obs"
      # "background-music" # requires fixing
      "nikitabobko/tap/aerospace"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
