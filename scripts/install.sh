#!/bin/sh

# TODO ansible
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/ansible.sh"
source "$SCRIPT_DIR/clone_repositories.sh"
source "$SCRIPT_DIR/simbolic_links.sh"
source "$SCRIPT_DIR/python_venv.sh"
