#!/bin/bash

CONFIG_DIR="$HOME/.config"
# create symbolic links
# sfv (symbolic force verbose) for idempotency
# dirs
PLATFORM=$(uname)
if [ "$PLATFORM" == "Darwin" ]; then
    FONTS_DIR="$HOME/Library/Fonts"

    SEARCH_DIR="$HOME/.dotfiles/desktop/fonts/NerdFonts" 
    for entry in "$SEARCH_DIR"/*
    do
        ln -sfv "$FONTS_DIR/$entry" "$SEARCH_DIR/$entry"
    done
elif [ "$PLATFORM" == "Linux" ]; then
    FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"
    ln -sfv "$HOME/.dotfiles/desktop/fonts/NerdFonts" $FONTS_DIR
    # programs
    mkdir -p "$HOME/.local/bin/"
    ln -sfv $(which fdfind) "$HOME/.local/bin/fd"
fi

ln -sfv "$HOME/.dotfiles/.config/nvim" $CONFIG_DIR/nvim
mkdir -p "$HOME/.config/kitty"
ln -sfv "$HOME/.dotfiles/.config/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
ln -sfv "$HOME/.dotfiles/.config/kitty/nightfox_kitty.conf" "$CONFIG_DIR/kitty/"
mkdir -p "$CONFIG_DIR/coc/"
mkdir -p "$CONFIG_DIR/coc/ultisnips"
ln -sfv "$HOME/.dotfiles/.config/coc/ultisnips" "$CONFIG_DIR/coc"

# files
ln -sfv "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"  
ln -sfv "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -sfv "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
