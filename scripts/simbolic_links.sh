#!/bin/sh

DEV="$HOME/dev"
FONTS_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="$HOME/.config"
# create symbolic links
# sfv (symbolic force verbose) for idempotency
# files
ln -sfv "$DEV/.dotfiles/.gitconfig" "$HOME/.gitconfig"  
ln -sfv "$DEV/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -sfv "$DEV/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
# dirs
ln -sfv "$DEV/.dotfiles/desktop/fonts/NerdFonts" $FONTS_DIR
ln -sfv "$DEV/.dotfiles/.config/nvim" $CONFIG_DIR
ln -sfv "$DEV/.dotfiles/.config/kitty" $CONFIG_DIR
ln -sfv "$DEV/.dotfiles/.config/coc/ultisnips" "$CONFIG_DIR/coc"
# programs
ln -sfv $(which fdfind) ~/.local/bin/fd
