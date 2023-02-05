# Dotfiles


## Installation

Update system packages if on Ubuntu.
```bash
sudo apt-get update && apt-get upgrade -y
```

Alternatively, install Homebrew if on MacOs.
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Vanilla installation

```bash
sudo curl https://raw.githubusercontent.com/Drew138/.dotfiles/main/scripts/install.sh | bash
```

### Install with user repositories

SSH config required (see below).
```bash
sudo curl https://raw.githubusercontent.com/Drew138/.dotfiles/main/scripts/install.sh | bash -s -- -r
```

### Install with kitty terminal

```bash
sudo curl https://raw.githubusercontent.com/Drew138/.dotfiles/main/scripts/install.sh | bash -s -- -k
```

### Install all

```bash
sudo curl https://raw.githubusercontent.com/Drew138/.dotfiles/main/scripts/install.sh | bash -s -- -k -r
```

## Tmux plugins

Start a tmux session and install plugins by pressing `<C-a> I`.


## SSH config
### Generate new ssh key

Ssh authentication is required to fetch some repositories during the installation. 

To generate a new ssh key run the following command.

```bash
cd ~/.ssh && ssh-keygen -t ed25519 -C "58788781+drew138@users.noreply.github.com"
```

Then add github to known hosts.

```bash
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
```

Copy contents of your public key file and add them to your github keys.

```
cat id_ed25519.pub
```
