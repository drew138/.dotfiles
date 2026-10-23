#!/bin/bash

set -euo pipefail

repository_url="https://github.com/Drew138/.dotfiles.git"
become_file="${HOME}/.become_pass"

cleanup() {
    rm -Pf "${become_file}" 2>/dev/null
    return 0
}

trap cleanup EXIT INT TERM

if ! command -v ansible-pull >/dev/null 2>&1; then
    printf 'ansible is not installed\n' >&2
    exit 1
fi

printf 'System password: '
read -r -s become_password
printf '\n'

umask 077
printf '%s\n' "${become_password}" >"${become_file}"

ansible-pull --url "${repository_url}" local.yml \
    --become-password-file "${become_file}" \
    "$@"
