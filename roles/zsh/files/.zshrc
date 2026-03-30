# set vim keybinds
bindkey -v

# poetry
fpath+=~/.zfunc

# initialize completion system
autoload -Uz compinit && compinit

# enable bash completion in zsh
autoload -U +X bashcompinit && bashcompinit

# homebrew configs
export HOMEBREW_NO_AUTO_UPDATE=1
export PATH="/opt/homebrew/bin:${PATH}"

# zinit
export ZINIT_HOME="${HOME}/.local/share/zinit"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light romkatv/zsh-defer
zsh-defer zinit light zsh-users/zsh-syntax-highlighting
zsh-defer zinit light zsh-users/zsh-completions
zsh-defer zinit light zsh-users/zsh-autosuggestions
zsh-defer zinit light Aloxaf/fzf-tab

compinit
zinit cdreplay -q

zinit ice as"command" from"gh-r" \
    atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
    atpull"%atclone" src"init.zsh"
zinit light starship/starship

export HISTSIZE=5000
export HISTFILE=~/.zsh_history
export SAVEHIST=${HISTSIZE}
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
zstyle ':fzf-tab:complete:(cd|cat|bat|vim|nano|nvim):*' popup-pad 30 0
zstyle ':fzf-tab:complete:(cd|cat|bat|vim|nano|nvim):*' fzf-preview '
if [ -d $realpath ]; then
  eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath
else
  bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath
fi'

# editor configs
export EDITOR='nvim'

# aliases
## prefix
alias vim='nvim'
alias unstage='git restore --staged'
alias merge='git mergetool'
alias abort='git reset --merge'
alias status='git status'
alias checkout='git checkout'
alias push='git push'
alias gdiff='if command -v bat >/dev/null 2>&1; then
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
  else
    git diff
  fi'
alias ..='cd ..'

### eza
if command -v eza 1>/dev/null 2>&1; then
    export FPATH="${HOME}/dev/eza/completions/zsh:${FPATH}"
    export EZA_CONFIG_DIR="${HOME}/.config/eza"
    alias l='eza --icons'
    alias ls='eza --icons'
    alias ll='eza -lah --icons --git'
    alias lt='eza --tree'
fi

## sufix
alias -s mov="open"
alias -s png="open"
alias -s mp4="open"
alias -s py="python3"

# bat
if command -v bat 1>/dev/null 2>&1; then
    alias cat='bat'
    export BAT_CONFIG_PATH="${HOME}/.config/bat/config"
    export BAT_CONFIG_DIR="${HOME}/.config/bat"
fi

# workrc configs
[ -f "${HOME}/.work.zsh" ] && \. "${HOME}/.work.zsh"

# scripts configs
export PATH="${HOME}/.dotfiles/roles/scripts/files:${PATH}"

# go configs
export PATH="${HOME}/go/bin:/usr/local/go/bin:${PATH}"

# local binaries
export PATH="${HOME}/.local/bin:${PATH}"

# nvm configs
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"

# fzf configs
if [ -f "${HOME}/.fzf.zsh" ]; then
    source "${HOME}/.fzf.zsh"

    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border \
    --color=hl:#f4a261,hl+:#f4a261,pointer:#f4a261,marker:#f4a261 \
    --preview 'if command -v bat >/dev/null 2>&1; then \
        bat --color=always --style=numbers --line-range=:500 {}; \
      else \
        cat {}; \
      fi'"

    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude .git"
    eval "$(fzf --zsh)"
fi

# rust configs
[ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"

# pyenv configs
if command -v pyenv 1>/dev/null 2>&1; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init -)"
fi

# python configs
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PYTEST_ADDOPTS="-p no:cacheprovider"

# custom commands
## open editor to write long commands
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
## magic space
bindkey ' ' magic-space

# zoxide
if  command -v zoxide 1>/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# kubectl
if command -v kubectl 1>/dev/null 2>&1; then
    source <(kubectl completion zsh)
fi

bashcompinit
# terraform
if command -v terraform 1>/dev/null 2>&1; then
    complete -o nospace -C "$(command -v terraform)" terraform
fi

# wezterm
[[ "$(uname -s)" == "Darwin" ]] && export PATH="${PATH}:/Applications/WezTerm.app/Contents/MacOS"

# clitools
export PATH="${HOME}/.clitools/bin:${PATH}"

# gcloud
# The next line updates PATH for the Google Cloud SDK.
[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ] && \. "${HOME}/google-cloud-sdk/path.zsh.inc"

# The next line enables shell command completion for gcloud.
[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ] && \. "${HOME}/google-cloud-sdk/completion.zsh.inc"
