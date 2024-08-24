# Dotfiles

A repository to automatically set up my workstation

<img src="https://raw.githubusercontent.com/drew138/.dotfiles/main/assets/Mac-Dev-Playbook-Logo.png" width="250" height="156" alt="Mac Dev Playbook Logo" />

[![CI][badge-gh-actions]][link-gh-actions]

## Installation

Install ansible and molecule.

```bash
pip3 install ansible molecule
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
