#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_DOWNLOAD_CONCURRENCY=1

cache="/tmp/sketchybar-brew-outdated.txt"
staging="${cache}.$$"
stamp="/tmp/sketchybar-brew-updated"

# sketchybar ignores SIGCHLD, and brew aborts on the missing exit status unless it is reset.
run_brew() {
    perl -e '$SIG{CHLD} = "DEFAULT"; exec @ARGV' /opt/homebrew/bin/brew "$@"
}

if [ -z "$(find "${stamp}" -newermt '-6 hours' 2>/dev/null)" ]; then
    run_brew update >/dev/null 2>&1
    touch "${stamp}"
fi

{
    run_brew outdated --verbose
} >"${staging}" 2>/dev/null

mv "${staging}" "${cache}"

/opt/homebrew/bin/sketchybar --trigger brew_update
