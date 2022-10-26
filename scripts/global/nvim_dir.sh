#!/bin/sh
FOLDER=fd --type d --hidden --exclude .git | fzf-tmux -p --reverse
cd "$FOLDER"
nvim "$FOLDER"
