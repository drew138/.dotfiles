#!/bin/sh

FONTS_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="$HOME/.config"
# create symbolic links
# sfv (symbolic force verbose) for idempotency
# files
ln -sfv "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"  
ln -sfv "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -sfv "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
# dirs
ln -sfv "$HOME/.dotfiles/desktop/fonts/NerdFonts" $FONTS_DIR
ln -sfv "$HOME/.dotfiles/.config/nvim" $CONFIG_DIR
mkdir -p "$HOME/.dotfiles/.config/kitty"
ln -sfv "$HOME/.dotfiles/.config/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
ln -sfv "$HOME/.dotfiles/.config/kitty/nightfox_kitty.conf" "$CONFIG_DIR/kitty/"
ln -sfv "$HOME/.dotfiles/.config/coc/ultisnips" "$CONFIG_DIR/coc"
# programs
mkdir -p "$HOME/.local/bin/"
ln -sfv $(which fdfind) "$HOME/.local/bin/fd"
