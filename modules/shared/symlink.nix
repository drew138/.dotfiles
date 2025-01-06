{ config, ... }:
let
  symlink = config.lib.file.mkOutOfStoreSymlink;
  homeDirectory = config.home.homeDirectory;
in
{
  home.file.".zshrc".source = symlink "${homeDirectory}/.dotfiles/.zshrc";
  home.file.".tmux.conf".source = symlink "${homeDirectory}/.dotfiles/.zshrc";
  home.file.".gitconfig".source = symlink "${homeDirectory}/.dotfiles/.gitconfig";
  home.file.".gitignore_global".source = symlink "${homeDirectory}/.dotfiles/.gitignore_global";
  home.file.".wezterm.lua".source = symlink "${homeDirectory}/.dotfiles/.wezterm.lua";
  home.file.".config/starship.toml".source = symlink "${homeDirectory}/.dotfiles/starship.toml";
}
