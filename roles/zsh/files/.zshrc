# starship configs
eval "$(starship init zsh)"

# editor configs
export EDITOR='nvim'

# aliases
alias vim='nvim'
alias unstage='git restore --staged .'
alias merge='git mergetool'
alias abort='git reset --merge'
alias status='git status'
alias checkout='git checkout'
alias push='git push'
alias gdiff='git diff --name-only --relative --diff-filter=d | xargs bat --diff'
alias ..='cd ..'
alias l='ls -F --color'
alias ls='ls -F --color'
alias la='ls -la'
alias ll='ls -l'
alias cat='bat'
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# workrc configs
[ -f $HOME/.workrc.zsh ] && \. $HOME/.workrc.zsh

# scripts configs
export PATH="$HOME/.dotfiles/roles/scripts/files:$PATH"

# go configs
export PATH="$HOME/go/bin:/usr/local/go/bin:$PATH"

# homebrew configs
export HOMEBREW_NO_AUTO_UPDATE=1

# nvm configs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# fzf configs
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# rust configs
[ -f $HOME/.cargo/env ] && source $HOME/.cargo/env

## pyenv configs
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# open editor to write long commands
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# zsh-z configs
source $HOME/dev/zsh-z/zsh-z.plugin.zsh
autoload -U compinit; compinit

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# zsh-autosuggestions configs
source $HOME/dev/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

# zsh-syntax-highlighting configs
source $HOME/dev/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
