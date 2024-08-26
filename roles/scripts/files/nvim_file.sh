#!/bin/bash
file=$(fd --type f --hidden --exclude .git | fzf-tmux -p --reverse)

if [ -n "$file" ]; then
    cd "$(dirname "$file")" || exit;
    nvim "$file"
fi
