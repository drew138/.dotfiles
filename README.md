# Dotfiles Installer

<p align="center">
  <img src="https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Dotfiles-Logo.png" alt="Dotfiles Logo" />
</p>

<div align="center">
  <img src="https://github.com/drew138/.dotfiles/actions/workflows/ci.yml/badge.svg?event=push" alt="CI Badge">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  <img src="https://img.shields.io/github/stars/drew138/.dotfiles?style=social" alt="GitHub Repo stars">
</div>

## Installation

Install homebrew and setup ansible.

```bash
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    export PATH="/usr/local/bin:$PATH"
fi
brew install git curl ansible molecule
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh)
```

reminder: system reboot might be required for some programs to work as expected.

### Caveats

#### Homebrew Casks

Some packages like `logitech-g-hub` impede automatic installation
without password prompting. For that reason, they are not included in the role.
They can be installed manually using the following command:

```bash
brew install --cask logitech-g-hub
```
