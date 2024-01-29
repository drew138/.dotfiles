#!/bin/bash

# scripts to enable HSF/HCF audio on Ubuntu.
# source: https://linuxconfig.org/how-to-install-pipewire-on-ubuntu-linux

sudo apt update

sudo apt install pipewire pipewire-audio-client-libraries

sudo apt install gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,media-session,bin,locales,tests}}

systemctl --user daemon-reload

systemctl --user --now disable pulseaudio.service pulseaudio.socket

systemctl --user --now enable pipewire pipewire-pulse

pactl info
