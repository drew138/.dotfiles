#!/bin/bash

function fetch_roles() {
    roles_url="https://api.github.com/repos/drew138/.dotfiles/contents/roles"
    if command -v curl &> /dev/null; then
        roles_response=$(curl -s "$roles_url")
    elif command -v wget &> /dev/null; then
        roles_response=$(wget -qO- "$roles_url")
    else
        echo "Neither curl nor wget is installed. Exiting."
        exit 1
    fi
    roles=$(
        echo "$roles_response" |  \
        grep "name" |  \
        sed -e 's/\"name\":\ \"//' -e 's/\"\,//' -e 's/\ //g'
    )
}

function read_credentials() {
    printf "Please enter your password: "
    read -r -s password
    printf "\n"
    printf "Please enter your ansible vault password: "
    read -r -s ansible_vault_password
    printf "\n"
}

function select_roles() {
    #TODO
    echo
}

function create_vault_password_file() {
    echo "$ansible_vault_password" > ~/.vault_pass
    ansible_vault_password_file=~/.vault_pass
}

function remove_vault_password_file() {
    rm ~/.vault_pass
}


function run_ansible() {
    repository_url="https://github.com/Drew138/.dotfiles.git"
    ansible-pull -U $repository_url local.yml \
    --vault-password-file "$ansible_vault_password_file"  \
    -e "
    {
        \"ansible_become_password\":\"$password\",
        \"selected_hosts\":\"localhost\",
        \"selected_roles\":[\"$selected_roles\"]
    }"
}

function run() {
    fetch_roles

    read_credentials

    select_roles

    create_vault_password_file && run_ansible && remove_vault_password_file
}

read_credentials
