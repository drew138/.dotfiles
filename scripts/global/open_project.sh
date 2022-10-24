#!/bin/sh

fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
fd --type d --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim

