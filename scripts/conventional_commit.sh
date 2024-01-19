#!/bin/bash

IS_INSIDE_GIT_REPO="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
if [ ! "$IS_INSIDE_GIT_REPO" ]; then
    echo "fatal: not a git repository (or any of the parent directories): .git"
    exit 1
fi

CONTAINS_CHANGES=$(git status)
if [[ ! "$CONTAINS_CHANGES" == *"Changes to be committed:"* ]]; then
    echo "$CONTAINS_CHANGES"
    exit 1
fi

TYPE=$(
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

if [ -z "$TYPE" ]; then
    exit 1
fi

TYPE="${TYPE%%:*}"

SCOPE=$(
    gum input --placeholder "commit scope" \
        --header="Scope" \
        --header.foreground="#9d79d6" \
        --prompt.foreground="#f4a261" \
        --cursor.foreground=""
)

test -n "$SCOPE" && SCOPE="($SCOPE)"

IS_BREAKING_CHANGE=$(
    gum choose No Yes \
        --header="Is it a breaking change?" \
        --header.foreground="#9d79d6" \
        --cursor.foreground="#f4a261"
)

if [ "$IS_BREAKING_CHANGE" = "Yes" ]; then
    SCOPE="$SCOPE!"
fi

SUMMARY=$(
    gum input --prompt "$TYPE$SCOPE: " \
        --header="Description" \
        --placeholder "summary of this change" \
        --header.foreground="#9d79d6" \
        --prompt.foreground="#f4a261" \
        --cursor.foreground=""
)

test -n "$SUMMARY" && git commit -m "$TYPE$SCOPE: $SUMMARY"
