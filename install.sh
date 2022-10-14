#!/bin/sh

if !type "$virtualenv" > /dev/null; then
  echo virtualenv not installed
  exit
fi

# repos
cd "$HOME"
git clone git@github.com:Drew138/algorithms.git
git clone git@github.com:Drew138/competitive-programming.git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm/

fonts_dir="$HOME/.local/share/fonts/"
nvim_dir="$HOME/.config"
mkdir -p $fonts_dir $nvim_dir

# create symbolic links
# files
ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
# dirs
ln -s "$HOME/.dotfiles/.local/share/fonts/Nerdfonts" $fonts_dir   
ln -s "$HOME/.dotfiles/.config/nvim" $nvim_dir

# set env for python file formatting
cd "$HOME/.dotfiles"
virtualenv env
source env/bin/activate && pip install -r requirements.txt
