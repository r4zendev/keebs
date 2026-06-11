#!/bin/bash
# Install to /usr/lib/systemd/system-sleep/bluetooth-restart.sh
# Fixes ZMK #3309: connect/disconnect storm after host S3 resume.
# BlueZ gets confused about device addresses after suspend; restarting
# bluetoothd forces clean reconnection.
if [ "$1" = "post" ]; then
    sleep 2
    systemctl restart bluetooth
fi
