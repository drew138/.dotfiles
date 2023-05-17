#!/bin/bash
FOLDER=`fd --type d --hidden --exclude .git | fzf-tmux -p --reverse`

if [ -n "$FOLDER" ]; then
    cd "$FOLDER";
    echo $FOLDER;
    nvim "$FOLDER";
fi
