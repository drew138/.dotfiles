#!/bin/bash

DIR="$HOME/.dotfiles"

SCRIPT_DIR="$DIR/scripts"

# sudo apt-get install ansible -y

install(){
  sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml
  "$SCRIPT_DIR/simbolic_links.sh"
  "$SCRIPT_DIR/python_venv.sh"
  "$SCRIPT_DIR/kitty_post_install.sh"
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
      echo "-r, --repos               install repositories"
      exit 0
      ;;
    -r|--repos)
      shift
      export USER_REPOSITORIES=true
      ;;
    *)
      break
      ;;
  esac
done

install
