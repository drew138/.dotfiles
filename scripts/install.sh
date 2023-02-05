#!/bin/bash

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

install(){
  sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml
  "$SCRIPT_DIR/simbolic_links.sh"
  "$SCRIPT_DIR/python_venv.sh"
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
      export USER_REPOSITORIES=true
      ;;
    -k|--kitty)
      shift
      export KITTY_TERMINAL=true
      break
      ;;
  esac
done

install
