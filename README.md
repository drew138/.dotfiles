<img src="https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Dotfiles Logo" />
![Dotfiles Logo](https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Dotfiles-Logo.png)

# Dotfiles Installer

[![ci][badge-gh-actions]][link-gh-actions]

Automate workstation setup with ansible

## Installation

Setup ansible for installation.

### Ubuntu Only

```bash
sudo apt update && sudo apt upgrade
sudo add-apt-repository universe
sudo apt install -y curl python3-pip git
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

[badge-gh-actions]: https://github.com/drew138/.dotfiles/actions/workflows/ci.yml/badge.svg?event=push
[link-gh-actions]: https://github.com/drew138/.dotfiles/actions?query=workflow%3Aci

<!-- [dotfiles-logo]: -->
