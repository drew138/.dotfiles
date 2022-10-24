#!/bin/sh

# if !type "$virtualenv" > /dev/null; then
#   echo virtualenv not installed
#   exit
# fi

# ansible
sudo apt-get install ansible
sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/ansible.yml

# clone repositories
REPOSITORY_NAMES="algorithms competitive-programming Drew138 graphics-app .dotfiles"

for REPOSITORY in $REPOSITORY_NAMES; do 
    if [ ! -d "$HOME/$REPOSITORY" ];
    then 
        git clone "git@github.com:Drew138/$REPOSITORY.git" "$HOME/$REPOSITORY/"
    fi
done

if [ ! -d ~/.tmux/plugins/tpm/ ];
then 
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm/
fi

FONTS_DIR="$HOME/.local/share/fonts/"
CONFIG_DIR="$HOME/.config"

# create symbolic links
# sfv (symbolic force verbose) for idempotency
ln -sfv "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"  
ln -sfv "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -sfv "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
# dirs
ln -sfv "$HOME/.dotfiles/desktop/fonts/NerdFonts" $FONTS_DIR
ln -sfv "$HOME/.dotfiles/.config/nvim" $CONFIG_DIR
ln -sfv "$HOME/.dotfiles/.config/kitty" $CONFIG_DIR
# programs
ln -sfv $(which fdfind) ~/.local/bin/fd

# set env for python file formatting and other utils
VENV_DIR="$HOME/.dotfiles/env"
if [ ! -d "$VENV_DIR" ];
then 
    virtualenv "$VENV_DIR"
fi
source "$VENV_DIR/env/bin/activate" && pip install -r requirements.txt
