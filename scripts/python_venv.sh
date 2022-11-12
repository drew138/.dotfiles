#!/bin/sh
# set env for python file formatting and other utils
VENV_DIR="$HOME/.dotfiles/env"
if [ ! -d "$VENV_DIR" ];
then 
    virtualenv "$VENV_DIR"
fi
"$VENV_DIR/env/bin/activate" && pip install -r requirements.txt
