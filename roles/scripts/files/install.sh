#!/bin/bash

read -p "Please enter your vault password: " -r -s password

echo "$password" > ~/.vault_pass

export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

ansible-pull -U https://github.com/Drew138/.dotfiles.git local.yml --extra-vars selected_roles=go

rm ~/.vault_pass

unset ANSIBLE_VAULT_PASSWORD_FILE
