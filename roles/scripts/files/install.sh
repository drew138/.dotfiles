#!/bin/bash

set -euo pipefail

repository_url="https://github.com/Drew138/.dotfiles.git"

if ! command -v ansible-pull >/dev/null 2>&1; then
    printf 'ansible is not installed\n' >&2
    exit 1
fi

ansible-pull --url "${repository_url}" local.yml --ask-become-pass "$@"
