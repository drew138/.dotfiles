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

Setup ansible for installation.

### Ubuntu Only

```bash
sudo apt update && sudo apt upgrade
sudo add-apt-repository universe
sudo apt install -y curl python3-pip python3-venv git
```

### Macos and Ubuntu

```bash
source <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/setup_ansible.sh)
```

### Install

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh)
```

reminder: system reboot might be required for some programs to work as expected.

### Caveats

#### Homebrew Casks

Some packages like `google-drive` and `logitech-g-hub` impede automatic installation
without password prompting. For that reason, they are not included in the role.
They can be installed manually using the following command:

```bash
brew install --cask google-drive logitech-g-hub
```

#### Flatpak

Some flatpak packages are not available for all system architectures.
For example, they may only available for `x86_64` systems.
To avoid errors, the `flatpak` role will not fail if a package can not be installed.
They can be installed manually through other means.
