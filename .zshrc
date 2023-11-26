# If you come from bash you might have to change your $PATH.
eval "$(starship init zsh)"

# PATH="$PATH:/home/$USER/.local/bin"
# PATH="$PATH:/home/$USER/go/bin"
# PATH="$PATH:/home/$USER/.go/bin"
# PATH="$PATH:/usr/local/go/bin"
# PATH="$HOME/bin:/usr/local/bin:$PATH"
# export GOPATH="$HOME/go"
# export PATH="$PATH:/$GOPATH/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

alias nd='. ~/.dotfiles/scripts/nvim_dir.sh'
alias nf='~/.dotfiles/scripts/nvim_file.sh'
alias vim='nvim'
alias unstage='git restore --staged .'
alias merge='git mergetool'
alias abort='git reset --merge'
alias status='git status'
alias checkout='git checkout .'
alias push='git push'
alias ..='cd ..'
alias l='ls -F --color'
alias ls='ls -F --color'
alias la='ls -la'
alias ll='ls -l'

export EDITOR='nvim'
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Disable homebrew auto update
export HOMEBREW_NO_AUTO_UPDATE=1

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.cargo/env ] && source ~/.cargo/env

[ -f ~/.workrc ] && source ~/.workrc

## pyenv configs
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

source $HOME/dev/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/dev/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
