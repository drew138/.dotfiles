#!/bin/bash

sudo apt-get install 'bluez*'

sudo apt-get install blueman

modprobe btusb

sudo systemctl restart bluetooth

# change ControllerMode settings in /etc/bluetooth/main.conf to ControllerMode = dual
sudo sed -i '0,|ControllerMode = .*$|{s|ControllerMode = .*$|ControllerMode = dual|}' /etc/bluetooth/main.conf
