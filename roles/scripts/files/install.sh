#!/bin/bash

set -euo pipefail

repository_url="https://github.com/Drew138/.dotfiles.git"
vault_file="${HOME}/.vault_pass"
become_file="${HOME}/.become_pass"

cleanup() {
    rm -Pf "${vault_file}" "${become_file}" 2>/dev/null
    return 0
}

trap cleanup EXIT INT TERM

if ! command -v ansible-pull >/dev/null 2>&1; then
    printf 'ansible is not installed\n' >&2
    exit 1
fi

printf 'Ansible vault password: '
read -r -s vault_password
printf '\nSystem password: '
read -r -s become_password
printf '\n'

umask 077
printf '%s\n' "${vault_password}" >"${vault_file}"
printf '%s\n' "${become_password}" >"${become_file}"

ansible-pull --url "${repository_url}" local.yml \
    --vault-password-file "${vault_file}" \
    --become-password-file "${become_file}" \
    "$@"
