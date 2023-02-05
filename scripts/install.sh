#!/bin/bash

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

install(){
  sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml --extra-vars "USER_REPOSITORIES=$USER_REPOSITORIES KITTY_TERMINAL=$KITTY_TERMINAL"
  "$SCRIPT_DIR/simbolic_links.sh"
  "$SCRIPT_DIR/python_venv.sh"
  "$SCRIPT_DIR/nvim_post_install.sh"
}
package="install.sh"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - automate work station installation"
      echo " "
      echo "$package [options] application [arguments]"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-r, --repos               install user repositories"
      echo "-k, --kitty               install kitty terminal"
      exit 0
      ;;
    -r|--repos)
      shift
      USER_REPOSITORIES=true
      continue
      ;;
    -k|--kitty)
      shift
      KITTY_TERMINAL=true
      continue
      ;;
    *)
      shift
      break
      ;;
  esac
done

install
