{ ... }: {
  homebrew = {
    enable = true;
    # required by python for scikit
    # learn god knows why
    brews = [
      "llvm" # required by python for scikit learn
      "libomp" # required by python for scikit learn
    ];
    casks = [
      "notion"
      "notion-calendar"
      "dropbox"
      "background-music" # requires fixing
      "nikitabobko/tap/aerospace"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
