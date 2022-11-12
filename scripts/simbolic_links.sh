#!/bin/sh

FONTS_DIR="~/.local/share/fonts"
CONFIG_DIR="~/.config"
# create symbolic links
# sfv (symbolic force verbose) for idempotency
# files
ln -sfv "~/.dotfiles/.gitconfig" "~/.gitconfig"  
ln -sfv "~/.dotfiles/.zshrc" "~/.zshrc"
ln -sfv "~/.dotfiles/.tmux.conf" "~/.tmux.conf"
# dirs
ln -sfv "~/.dotfiles/desktop/fonts/NerdFonts" $FONTS_DIR
ln -sfv "~/.dotfiles/.config/nvim" $CONFIG_DIR
mkdir -p "~/.dotfiles/.config/kitty"
ln -sfv "~/.dotfiles/.config/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
ln -sfv "~/.dotfiles/.config/kitty/nightfox_kitty.conf" "$CONFIG_DIR/kitty/"
ln -sfv "~/.dotfiles/.config/coc/ultisnips" "$CONFIG_DIR/coc"
# programs
mkdir -p ~/.local/bin/
ln -sfv $(which fdfind) ~/.local/bin/fd
