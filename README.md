<img src="https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Mac Dev Playbook Logo" />

# Dotfiles Installer

[![ci][badge-gh-actions]][link-gh-actions]

Automate workstation setup with ansible

## Installation

Install ansible and molecule.

```bash
pip3 install ansible
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
curl -O https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh && chmod +x install.sh && ./install.sh  && rm install.sh
```

reminder: system reboot might be required for some software to work as expected.

[badge-gh-actions]: https://github.com/drew138/.dotfiles/actions/workflows/ci.yml/badge.svg?event=push
[link-gh-actions]: https://github.com/drew138/.dotfiles/actions?query=workflow%3Aci

```
python3 -m ansible-pull -U https://github.com/Drew138/.dotfiles.git local.yml --vault-password-file /Users/drew/.ansible_vault --extra-vars {"selected_hosts":"localhost","selected_roles":["zsh"]}

```
