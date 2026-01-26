#!/bin/bash

remote_repository=$(git config --get remote.origin.url)
repository_url=${remote_repository%.git}

if ! [[ ${repository_url} == https* ]]; then
    repository_url=$(echo "${repository_url}" | sed 's/\:/\//g')
    repository_url=$(echo "${repository_url}" | sed 's/git@/https:\/\//g')
fi

open "${repository_url}"
