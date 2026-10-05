#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_DOWNLOAD_CONCURRENCY=1

log="/tmp/sketchybar-brew-upgrade.log"
lock="/tmp/sketchybar-brew-upgrade.lock"

if ! mkdir "${lock}" 2>/dev/null; then
    exit 0
fi

trap 'rmdir "${lock}" 2>/dev/null' EXIT

# sketchybar ignores SIGCHLD, and brew aborts on the missing exit status unless it is reset.
run_brew() {
    perl -e '$SIG{CHLD} = "DEFAULT"; exec @ARGV' /opt/homebrew/bin/brew "$@"
}

{
    run_brew update
    run_brew upgrade "$@"
} >"${log}" 2>&1

status=$?

/opt/homebrew/bin/sketchybar --trigger brew_upgrade_finished STATUS="${status}"
