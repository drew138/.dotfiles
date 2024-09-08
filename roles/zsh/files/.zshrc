# set vim keybinds
bindkey -v

# poetry
fpath+=~/.zfunc
alias poetry="$HOME/.clitools/bin/poetry"

# pre-commit
alias pre-commit="$HOME/.clitools/bin/pre-commit"

# ansible
alias ansible="$HOME/.clitools/bin/ansible"
alias ansible-pull="$HOME/.clitools/bin/ansible-pull"

# initialize completion system
autoload -Uz compinit && compinit

# enable bash completion in zsh
autoload -U +X bashcompinit && bashcompinit

# zinit
export ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light romkatv/zsh-defer
zsh-defer zinit light zsh-users/zsh-syntax-highlighting
zsh-defer zinit light zsh-users/zsh-completions
zsh-defer zinit light zsh-users/zsh-autosuggestions
zsh-defer zinit light Aloxaf/fzf-tab

zinit cdreplay -q

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

export HISTSIZE=5000
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE
export HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath | command fzf'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

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
export PATH="/opt/homebrew/bin:$PATH"

# nvm configs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# fzf configs
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
eval "$(fzf --zsh)"

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

# zoxide
export PATH="$HOME/.local/bin:$PATH"
if ! command -v zoxide 1>/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

eval "$(zoxide init --cmd cd zsh)"

# kubectl
source <(kubectl completion zsh)

# terraform
complete -o nospace -C /usr/local/bin/terraform terraform

# wezterm
[[ "$(uname -s)" == "Linux" ]] && alias wezterm='flatpak run org.wezfurlong.wezterm'

[[ "$(uname -s)" == "Darwin" ]] && export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

# gcloud
# The next line updates PATH for the Google Cloud SDK.
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && \. "$HOME/google-cloud-sdk/path.zsh.inc"

# The next line enables shell command completion for gcloud.
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && \. "$HOME/google-cloud-sdk/completion.zsh.inc"
