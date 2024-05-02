#!/bin/bash
sudo apt-get update
sudo apt install nfs-kernel-server

SHARED_DIRECTORY="/mnt/nfs_share"

sudo mkdir -p $SHARED_DIRECTORY

sudo chown nobody:nogroup $SHARED_DIRECTORY

sudo systemctl restart nfs-kernel-server


