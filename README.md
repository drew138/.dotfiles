# Dotfiles

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
