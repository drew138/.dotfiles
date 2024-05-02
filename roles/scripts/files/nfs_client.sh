#!/bin/bash

sudo apt update

sudo apt install nfs-common


MOUNT_DIRECTORY=""

sudo mkdir -p "$MOUNT_DIRECTORY"

sudo mount host_ip:/mnt/volume-nyc3-01/nfs/ "$MOUNT_DIRECTORY"

