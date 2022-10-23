#!/bin/sh

if !type "$virtualenv" > /dev/null; then
  echo virtualenv not installed
  exit
fi

# repos
cd "$HOME"
git clone git@github.com:Drew138/algorithms.git
git clone git@github.com:Drew138/competitive-programming.git
git clone git@github.com:Drew138/Drew138.git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm/

FONTS_DIR="$HOME/.local/share/fonts/"
CONFIG_DIR="$HOME/.config"

# create symbolic links
# files
ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
# dirs
ln -s "$HOME/.dotfiles/.local/share/fonts/Nerdfonts" $FONTS_DIR   
ln -s "$HOME/.dotfiles/.config/nvim" $CONFIG_DIR
ln -s "$HOME/.dotfiles/.config/kitty" $CONFIG_DIR

# set env for python file formatting
cd "$HOME/.dotfiles"
virtualenv env
source env/bin/activate && pip install -r requirements.txt
