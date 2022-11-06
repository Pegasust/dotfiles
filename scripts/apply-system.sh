#!/usr/bin/env sh
set -xv

# Where is this script located
SCRIPT_DIR=$(realpath $(dirname $0))
echo "SCRIPT_DIR: ${SCRIPT_DIR}"
# Where should the symlink for this repo live in the system
CONFIG_DIR="~/.dotfiles"

# Create a symlink for this directory to ~/.dotfiles
# if it already exists, error out
if [ -L ${CONFIG_DIR} ] && [ $(readlink -f ${CONFIG_DIR}) != ${SCRIPT_DIR} ]; then
	echo "ERR: ${SCRIPT_DIR}/apply-system.sh: ${CONFIG_DIR} exists and not symlink to ${SCRIPT_DIR}"
	exit 1
fi
ln -s -T ${SCRIPT_DIR} ${CONFIG_DIR}


# $PWD to ~/.dotfiles
pushd ~/.dotfiles
sudo nixos-rebuild switch --flake .#nixos
popd
