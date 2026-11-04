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

### SSH keys

SSH keys live in Bitwarden, whose SSH agent signs for them; no private key is written to disk.
The `ssh` role installs Bitwarden through its `casks` dependency, before any role that clones over
SSH. When the agent does not hold the github key yet, the role opens Bitwarden and waits: log in,
unlock it, and turn on Settings → Enable SSH agent the first time. It checks every 5 seconds,
continues as soon as the key is there, and stops after 15 minutes if it never is.

CI sets `DOTFILES_CI=true` and writes its own github key to `~/.ssh/github`, so these steps are
skipped there.

| Bitwarden item | Used for |
|---|---|
| `Github auth keys` | GitHub over SSH; the `ssh` role finds its public key in the agent by this name, and its private key is also the `SSH_GITHUB_KEY` CI secret |
| `Homelab keys` | logging in to the Pi; set up by the homelab repo's `scripts/setup-ssh.sh` |
| `Git signing keys` | signing commits |

Their public keys are in `roles/ssh/vars/main.yml`.

### Install

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh)
```

The script asks for the system password, then runs every role. The password is written to a file
only readable by the current user and removed when the run ends.

To install a subset of the roles, pass them through to ansible:

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh) \
    --extra-vars '{"selected_roles": ["zsh", "nvim", "sketchybar"]}'
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
