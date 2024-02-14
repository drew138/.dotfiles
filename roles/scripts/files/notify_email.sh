#!/bin/bash

if [ "$1" != "success" ]; then
    send_email
    exit 1
fi

if [ "$2" != "success" ]; then
    send_email
    exit 1
fi

send_email() {
    local recipient="$EMAIL"
    local subject="Dotfiles Error"
    local body
    body="dotfiles test failed on $(date '+%Y-%m-%d'), check needed"
    echo "$body" | mail -s "$subject" "$recipient"
}
