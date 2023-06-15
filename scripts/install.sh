#!/bin/bash

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

install(){
  sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml \
      --extra-vars \
      "user_repositories=$USER_REPOSITORIES \
      kitty_terminal=$KITTY_TERMINAL \
      extra_software=$EXTRA_SOFTWARE"

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
      echo "-s, --software            install additional software"
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
    -s|--software)
      shift
      EXTRA_SOFTWARE=true
      ;;
    *)
      shift
      break
      ;;
  esac
done

install
