#!/usr/bin/env sh
SCRIPT_DIR=$(realpath $(dirname $0))

function mntDrive() {
    WSL_DRIVE=$(echo $1 | tr '[:upper:]' '[:lower:]')
    ${SCRIPT_DIR}/mount-windrive.sh $1 $WSL_DRIVE
    echo "ls /mnt/${WSL_DRIVE}"
    ls /mnt/${WSL_DRIVE}
}

mntDrive C
mntDrive D
mntDrive F

