#!/bin/bash

export PATH="/opt/homebrew/bin:${HOME}/.local/bin:/usr/bin:/bin"

# a bare `activate` or `open -a` would launch WezTerm; this check does not.
if [ "$(osascript -e 'application "WezTerm" is running')" != "true" ]; then
    exit 0
fi

osascript -e 'tell application "WezTerm" to activate'

test -n "$1" && herdr workspace focus "$1"
test -n "$2" && herdr agent focus "$2"
