#!/bin/sh

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

test -n "$SUMMARY" && git commit -m "$SUMMARY"