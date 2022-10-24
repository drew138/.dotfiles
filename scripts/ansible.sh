#!/bin/sh

# ansible
sudo apt-get install ansible
sudo ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml
