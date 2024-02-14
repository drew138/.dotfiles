#!/bin/bash

echo -n "Please enter your vault password: "

read -r -s password

pip3 install ansible molecule

echo "$password" > ~/.vault_pass

export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

ansible-pull -U https://github.com/Drew138/.dotfiles.git ansible/local.yml

rm ~/.vault_pass

unset ANSIBLE_VAULT_PASSWORD_FILE
