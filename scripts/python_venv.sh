#!/bin/bash
# set env for python file formatting and other utils
DOTFILES_DIR="$HOME/.dotfiles/"
VENV_DIR="$DOTFILES_DIR/env/"
if [ ! -d "$VENV_DIR" ];
then 
    virtualenv "$VENV_DIR"
fi
. "$VENV_DIR/bin/activate" 
pip install -r "$DOTFILES_DIR/requirements.txt"
