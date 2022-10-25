#!/bin/sh


# TODO use ansible for this
# - name: Download the NodeJS code from the GitRepo
         # become: yes
         # git:
         #    repo: 'https://{{gituser}}:{{gitpass}}@github.com/AKSarav/SampleNodeApp.git'
         #    dest: "{{ destdir }}"
# clone repositories
REPOSITORY_NAMES="algorithms competitive-programming Drew138 graphics-app"

DEV="$HOME/dev"
mkdir -p "$DEV"
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
