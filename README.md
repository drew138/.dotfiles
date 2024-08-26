<img src="https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Mac Dev Playbook Logo" />

# Dotfiles Installer

[![ci][badge-gh-actions]][link-gh-actions]

Automate workstation setup with ansible

## Installation

Setup ansible for installation.

```bash
source <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/setup_ansible.sh)
```

### Set ansible vault password

```bash
echo "<password>" > ~/.ansible_vault
```

### Set ansible vault password environment variable

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault
```

### Install all

```bash
curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh | bash
```

reminder: system reboot might be required for some software to work as expected.

[badge-gh-actions]: https://github.com/drew138/.dotfiles/actions/workflows/ci.yml/badge.svg?event=push
[link-gh-actions]: https://github.com/drew138/.dotfiles/actions?query=workflow%3Aci
