#!/bin/bash
folder=$(fd --type d --hidden --exclude .git | fzf-tmux -p --reverse)

if [ -n "$folder" ]; then
    cd "$folder" || exit;
    nvim "$folder";
fi
