{ ... }:
{
  home-manager.users.drew = { config, pkgs, ... }:
    {
      # home.file = import ./symlink.nix { inherit config; };
      home.file =
        let
          symlink = config.lib.file.mkOutOfStoreSymlink;
          homeDirectory = config.home.homeDirectory;
        in
        {
          ".zshrc".source = symlink "${homeDirectory}/.dotfiles/.zshrc";
          ".tmux.conf".source = symlink "${homeDirectory}/.dotfiles/.zshrc";
          ".gitconfig".source = symlink "${homeDirectory}/.dotfiles/.gitconfig";
          ".gitignore_global".source = symlink "${homeDirectory}/.dotfiles/.gitignore_global";
          ".wezterm.lua".source = symlink "${homeDirectory}/.dotfiles/.wezterm.lua";
          ".config/starship.toml".source = symlink "${homeDirectory}/.dotfiles/starship.toml";
          ".config/nvim".source = symlink "${homeDirectory}/.dotfiles/roles/nvim/files";
        };
      home.activation = import ./scripts.nix {
        inherit pkgs;
      };
    };
}
