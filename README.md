# Dotfiles

## Generate new ssh key

Ssh authentication is required to fetch some repositories during the installation. To generate a new ssh key run the following command.

```bash
cd ~/.ssh && ssh-keygen -t ed25519 -C "58788781+drew138@users.noreply.github.com"
```

## Installation

```bash
sudo curl https://raw.githubusercontent.com/Drew138/.dotfiles/main/scripts/install.sh | bash
```
