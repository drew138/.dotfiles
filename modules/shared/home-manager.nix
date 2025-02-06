{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    {
      # home.file = import ./symlink.nix { config = args.config; };
      home.file =
        {
          ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.zshrc";
          ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.zshrc";
          ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.gitconfig";
          ".gitignore_global".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.gitignore_global";
          ".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.wezterm.lua";
          ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/starship.toml";
          ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/roles/nvim/files";
        };
      # home.activation = import ./scripts.nix {
      #   pkgs = args.pkgs;
      # };
    };
}
