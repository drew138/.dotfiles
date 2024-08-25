#!/bin/bash

pip3 install ansible

ansible_binaries_location=$(pip3 show ansible | grep Location | awk '{print $2}' | sed 's/lib.*/bin/')

export PATH="$ansible_binaries_location:$PATH"
