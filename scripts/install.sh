#!/bin/sh

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install ansible -y
sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml

"$SCRIPT_DIR/simbolic_links.sh"
"$SCRIPT_DIR/python_venv.sh"
