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

Apple silicon only. Homebrew is expected at `/opt/homebrew`, and the roles assume it.

Install homebrew and setup ansible.

```bash
if [ ! -f /opt/homebrew/bin/brew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install git curl ansible molecule
```

### Install

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh)
```

The script asks for the ansible vault password and the system password, then runs every role.
Both are written to files only readable by the current user and removed when the run ends.

To install a subset of the roles, pass them through to ansible:

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh) \
    --extra-vars "selected_roles=['zsh','nvim','sketchybar']"
```

reminder: system reboot might be required for some programs to work as expected.

## macOS settings

This repo sets a number of macOS options programmatically, and Apple regularly renames or
removes those keys between releases — a `defaults write` to a dropped key succeeds and does
nothing, so reading the value back proves nothing. [MACOS-SETTINGS.md](MACOS-SETTINGS.md) is a
checklist of what to actually look at after a macOS upgrade to confirm each setting still
changes the machine's behaviour.

### Caveats

#### Homebrew Casks

Some packages like `logitech-g-hub` impede automatic installation
without password prompting. For that reason, they are not included in the role.
They can be installed manually using the following command:

```bash
brew install --cask logitech-g-hub
```
