#!/bin/sh

# TODO check ssh connection is workign
DIR="$HOME/.dotfiles"
if [ ! -d "$DIR" ];
then 
    git clone "git@github.com:Drew138/.dotfiles.git" "$DIR"
fi

SCRIPT_DIR="$DIR/scripts"
source "$SCRIPT_DIR/ansible.sh"
source "$SCRIPT_DIR/simbolic_links.sh"
source "$SCRIPT_DIR/python_venv.sh"
source "$SCRIPT_DIR/nvim.sh"
