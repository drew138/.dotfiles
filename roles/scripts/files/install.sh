#!/bin/bash

set -euo pipefail

# ansible-pull reads ansible-playbook's output through a pipe, which Python buffers
# until the run ends unless output is unbuffered.
export PYTHONUNBUFFERED=1

repository_url="https://github.com/Drew138/.dotfiles.git"

if [ ! -x /opt/homebrew/bin/brew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install git curl ansible molecule
# These casks ask for a password while installing, which the casks role cannot answer,
# so they are installed here where you can type it.
brew install --cask logitech-g-hub tailscale-app sf-symbols font-sf-mono font-sf-pro

ansible-pull --url "${repository_url}" local.yml --ask-become-pass
