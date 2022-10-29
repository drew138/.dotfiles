#!/bin/sh
FOLDER=`fd --type d --hidden --exclude .git | fzf-tmux -p --reverse`

# echo "$FOLDER"
if [ -n "$FOLDER" ]; then
    nvim "$FOLDER"
fi
