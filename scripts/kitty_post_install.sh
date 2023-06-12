#!/bin/bash
# Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in
# your system-wide PATH)
ln -sfv "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/"
# Place the kitty.desktop file somewhere it can be found by the OS
mkdir -p "$HOME/.local/share/applications/"
cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
# Update the paths to the kitty and its icon in the kitty.desktop file(s)
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty*.desktop"
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" "$HOME/.local/share/applications/kitty*.desktop"
