#!/bin/bash
FILE=`fd --type f --hidden --exclude .git | fzf-tmux -p --reverse`

if [ -n "$FILE" ]; then
    cd $(dirname "$FOLDER");
    nvim "$FILE"
fi
