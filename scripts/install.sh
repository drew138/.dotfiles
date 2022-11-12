#!/bin/sh

ssh -T git@github.com

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

sudo apt-get install ansible
sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml

"$SCRIPT_DIR/simbolic_links.sh"
"$SCRIPT_DIR/python_venv.sh"
source "$SCRIPT_DIR/nvim.sh"
