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

Apple silicon only. Run the installer:

```bash
bash <(curl -s https://raw.githubusercontent.com/drew138/.dotfiles/main/roles/scripts/files/install.sh)
```

It installs Homebrew, then ansible and the packages it needs, then runs ansible with every role.
Expect a few password prompts: Homebrew and some casks ask while installing, and ansible asks once
for the system password (`BECOME password:`).

### SSH keys

SSH keys live in Bitwarden, whose SSH agent signs for them; no private key is written to disk.
The `ssh` role installs Bitwarden through its `casks` dependency, before any role that clones over
SSH. When the agent does not hold the github key yet, the role opens Bitwarden and waits: log in,
unlock it, and turn on Settings → Enable SSH agent the first time. It checks every 5 seconds,
continues as soon as the key is there, and stops after 15 minutes if it never is.

reminder: system reboot might be required for some programs to work as expected.

## macOS settings

This repo sets a number of macOS options programmatically, and Apple regularly renames or
removes those keys between releases — a `defaults write` to a dropped key succeeds and does
nothing, so reading the value back proves nothing. [MACOS-SETTINGS.md](MACOS-SETTINGS.md) is a
checklist of what to actually look at after a macOS upgrade to confirm each setting still
changes the machine's behaviour.

### Caveats

#### Homebrew Casks

Some packages like `logitech-g-hub`, `tailscale-app` and Apple's `sf-symbols`, `font-sf-mono` and `font-sf-pro` impede automatic installation
without password prompting. For that reason, they are not included in the role; `install.sh`
installs them before running ansible.
