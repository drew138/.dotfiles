#!/bin/bash

INSIDE_GIT_REPO="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
if [ ! "$INSIDE_GIT_REPO" ]; then
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
        "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert" \
        --header.foreground="#9d79d6" \
        --cursor.foreground="#f4a261"
)

if [ -z "$TYPE" ]; then
    exit 1
fi

SCOPE=$(
    gum input --placeholder "commit scope" \
        --header="Scope" \
        --header.foreground="#9d79d6" \
        --prompt.foreground="#f4a261" \
        --cursor.foreground=""
)

test -n "$SCOPE" && SCOPE="($SCOPE)"

BREAKING_CHANGE=$(
    gum choose No Yes \
        --header="Is it a breaking change?" \
        --header.foreground="#9d79d6" \
        --cursor.foreground="#f4a261"
)

if [ "$BREAKING_CHANGE" = "Yes" ]; then
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
