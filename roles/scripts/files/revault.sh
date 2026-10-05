#!/bin/bash

set -euo pipefail

private_key="${HOME}/.ssh/id_ed25519"
public_key="${HOME}/.ssh/id_ed25519.pub"
vars_file="${HOME}/.dotfiles/roles/ssh/vars/main.yml"
minimum_words=5
minimum_characters=20

passphrase=""
passphrase_file=""
staging_file=""

cleanup() {
    [ -n "${passphrase_file}" ] && rm -Pf "${passphrase_file}" 2>/dev/null
    [ -n "${staging_file}" ] && rm -Pf "${staging_file}" 2>/dev/null
    return 0
}

trap cleanup EXIT INT TERM

usage() {
    printf 'usage: %s [passphrase | --file PATH | -]\n' "$(basename "$0")" >&2
    exit 1
}

case "${1:-}" in
    --file)
        [ -n "${2:-}" ] || usage
        [ -f "${2}" ] || { printf '%s does not exist\n' "${2}" >&2; exit 1; }
        passphrase=$(head -n 1 "${2}")
        ;;
    -)
        IFS= read -r passphrase
        ;;
    --help | -h)
        usage
        ;;
    "")
        printf 'New vault passphrase: '
        read -r -s passphrase
        printf '\nConfirm passphrase: '
        read -r -s confirmation
        printf '\n'
        [ "${passphrase}" = "${confirmation}" ] || { printf 'the passphrases do not match\n' >&2; exit 1; }
        ;;
    *)
        passphrase="${1}"
        ;;
esac

for binary in ansible-vault ansible; do
    command -v "${binary}" >/dev/null 2>&1 || { printf '%s is not on PATH\n' "${binary}" >&2; exit 1; }
done

for file in "${private_key}" "${public_key}" "${vars_file}"; do
    [ -f "${file}" ] || { printf '%s does not exist\n' "${file}" >&2; exit 1; }
done

words=$(printf '%s' "${passphrase}" | tr -cs '[:alnum:]' '\n' | grep -c .)
characters=${#passphrase}

if [ "${words}" -lt "${minimum_words}" ] && [ "${characters}" -lt "${minimum_characters}" ]; then
    printf 'use at least %s words or %s characters, this one has %s words and %s characters\n' \
        "${minimum_words}" "${minimum_characters}" "${words}" "${characters}" >&2
    exit 1
fi

umask 077
passphrase_file=$(mktemp)
staging_file=$(mktemp)

printf '%s\n' "${passphrase}" >"${passphrase_file}"

{
    echo '---'
    ansible-vault encrypt_string \
        --vault-password-file "${passphrase_file}" \
        --stdin-name 'ssh_github_private_key' <"${private_key}" 2>/dev/null
    ansible-vault encrypt_string \
        --vault-password-file "${passphrase_file}" \
        --stdin-name 'ssh_github_public_key' <"${public_key}" 2>/dev/null
} >"${staging_file}"

ansible localhost \
    --module-name debug \
    --args 'msg=ok' \
    --extra-vars "@${staging_file}" \
    --vault-password-file "${passphrase_file}" >/dev/null

cp "${staging_file}" "${vars_file}"
chmod 644 "${vars_file}"

printf 'rewrote %s with a %s word, %s character passphrase\n' "${vars_file}" "${words}" "${characters}"
printf 'update the ANSIBLE_VAULT_PASSWORD repository secret before pushing\n'
