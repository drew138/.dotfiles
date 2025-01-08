{ pkgs, ... }: {
  system.defaults = {
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
    dock = {
      autohide = true;
      launchanim = false;
      show-recents = false;
      tilesize = 36;
      persistent-apps = [
        "/Applications/System Settings.app"
        # "${pkgs.postman}/Applications/Postman.app"
        # "${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
        # "${pkgs.wezterm}/Applications/WezTerm.app"
        # "${pkgs.slack}/Applications/Slack.app"
        # "${pkgs.google-chrome}/Applications/Google Chrome.app"
        # "${pkgs.whatsapp-for-mac}/Applications/WhatsApp.app"
        # "${pkgs.spotify}/Applications/Spotify.app"
        # "${pkgs.discord}/Applications/Discord.app"
        # "${pkgs.utm}/Applications/UTM.app"

      ];
    };
    finder.FXPreferredViewStyle = "Nlsv";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
  };
}
