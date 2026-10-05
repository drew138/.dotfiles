#!/bin/bash

set -euo pipefail

private_key="${HOME}/.ssh/id_ed25519"
public_key="${HOME}/.ssh/id_ed25519.pub"
vars_file="${HOME}/.dotfiles/roles/ssh/vars/main.yml"
minimum_words=5

passphrase_file=""
plaintext_file=""

cleanup() {
    [ -n "${passphrase_file}" ] && rm -Pf "${passphrase_file}" 2>/dev/null
    [ -n "${plaintext_file}" ] && rm -Pf "${plaintext_file}" 2>/dev/null
    return 0
}

trap cleanup EXIT INT TERM

for binary in ansible-vault ansible; do
    if ! command -v "${binary}" >/dev/null 2>&1; then
        printf '%s is not on PATH\n' "${binary}" >&2
        exit 1
    fi
done

for file in "${private_key}" "${public_key}" "${vars_file}"; do
    if [ ! -f "${file}" ]; then
        printf '%s does not exist\n' "${file}" >&2
        exit 1
    fi
done

printf 'New vault passphrase: '
read -r -s passphrase
printf '\nConfirm passphrase: '
read -r -s confirmation
printf '\n'

if [ "${passphrase}" != "${confirmation}" ]; then
    printf 'the passphrases do not match\n' >&2
    exit 1
fi

words=$(printf '%s' "${passphrase}" | tr -cs '[:alnum:]' '\n' | grep -c .)

if [ "${words}" -lt "${minimum_words}" ]; then
    printf 'use at least %s words, this one has %s\n' "${minimum_words}" "${words}" >&2
    exit 1
fi

umask 077
passphrase_file=$(mktemp)
plaintext_file=$(mktemp)

printf '%s\n' "${passphrase}" >"${passphrase_file}"

{
    echo '---'
    echo 'ssh_github_private_key: |'
    sed 's/^/  /' "${private_key}"
    echo 'ssh_github_public_key: |'
    sed 's/^/  /' "${public_key}"
} >"${plaintext_file}"

ansible-vault encrypt \
    --vault-password-file "${passphrase_file}" \
    --output "${vars_file}" \
    "${plaintext_file}" >/dev/null

ansible localhost \
    --module-name debug \
    --args 'msg=ok' \
    --extra-vars "@${vars_file}" \
    --vault-password-file "${passphrase_file}" >/dev/null

printf 'encrypted %s with a %s word passphrase\n' "${vars_file}" "${words}"
printf 'update the ANSIBLE_VAULT_PASSWORD repository secret before pushing\n'
