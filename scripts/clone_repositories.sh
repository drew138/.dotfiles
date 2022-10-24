#!/bin/sh

# clone repositories
REPOSITORY_NAMES="algorithms competitive-programming Drew138 graphics-app .dotfiles"

DEV="$HOME/dev"
for REPOSITORY in $REPOSITORY_NAMES; do 
    if [ ! -d "$DEV/$REPOSITORY" ];
    then 
        git clone "git@github.com:Drew138/$REPOSITORY.git" "$DEV/$REPOSITORY/"
    fi
done

if [ ! -d ~/.tmux/plugins/tpm/ ];
then 
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm/
fi
