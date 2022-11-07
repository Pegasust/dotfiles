#!/usr/bin/env sh

# https://linuxnightly.com/mount-and-access-hard-drives-in-windows-subsystem-for-linux-wsl/
# Usage: scripts/mount-windrive.sh C # /mnt/c -> C:\

WIN_DRIVE_CHAR=${1:-"C"}
WSL_DRIVE_CHAR=${2:-$(echo $WIN_DRIVE_CHAR | tr '[:upper:]' '[:lower:]')}

sudo umount "/mnt/${WSL_DRIVE_CHAR}"
sudo mount -t drvfs "${WIN_DRIVE_CHAR}:" "/mnt/${WSL_DRIVE_CHAR}"

