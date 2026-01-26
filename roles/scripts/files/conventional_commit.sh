#!/bin/bash

is_inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
if [ ! "${is_inside_git_repo}" ]; then
    echo "fatal: not a git repository (or any of the parent directories): .git"
    exit 1
fi

contains_changes=$(git status)
if [[ ! "${contains_changes}" == *"Changes to be committed:"* ]]; then
    echo "${contains_changes}"
    exit 1
fi

type=$(
    gum choose --header="Commit Type" \
        "feat:      A new feature" \
        "fix:       A bug fix" \
        "docs:      Documentation only changes" \
        "style:     Changes that do no affect the meaning of the code (formatting)" \
        "refactor:  A code change that neither fixes a bug or adds a feature" \
        "perf:      A code change that improves performance" \
        "test:      Adding missing tests" \
        "chore:     Changes to the build process or auxiliary tools"  \
        --header.foreground="#9d79d6" \
        --cursor.foreground="#f4a261"
)

if [ -z "${type}" ]; then
    exit 1
fi

type="${type%%:*}"

scope=$(
    gum input --placeholder "commit scope" \
        --header="Scope" \
        --header.foreground="#9d79d6" \
        --prompt.foreground="#f4a261" \
        --cursor.foreground=""
)

test -n "${scope}" && scope="(${scope})"

is_breaking_change=$(
    gum choose No Yes \
        --header="Is it a breaking change?" \
        --header.foreground="#9d79d6" \
        --cursor.foreground="#f4a261"
)

if [ "${is_breaking_change}" = "Yes" ]; then
    scope="${scope}!"
fi

summary=$(
    gum input --prompt "${type}${scope}: " \
        --header="Description" \
        --placeholder "summary of this change" \
        --header.foreground="#9d79d6" \
        --prompt.foreground="#f4a261" \
        --cursor.foreground=""
)

test -n "${summary}" && git commit -m "${type}${scope}: ${summary}"
