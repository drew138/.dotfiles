#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
    brew install qmk/qmk/qmk
else
    sudo apt install -y git python3-pip
    python3 -m venv .env
    . .env/bin/activate
    python3 -m pip install --user qmk
fi
