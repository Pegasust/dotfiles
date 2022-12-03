#!/usr/bin/env sh
# NOTE: Untested on case of no home-manager
set -xv

# Where this script located
SCRIPT_DIR=$(realpath $(dirname $0))
echo "SCRIPT_DIR: ${SCRIPT_DIR}"

HOME_MANAGER_DIR="${SCRIPT_DIR}/../nix-conf/home-manager"

# test if we have home-manager, if not, attempt to use nix to put home-manager to
# our environment
if [ $(home-manager &>/dev/null) ]; then
    nix-shell -p home-manager --run "home-manager switch --flake $HOME_MANAGER_DIR"
else
    home-manager switch --flake "$HOME_MANAGER_DIR"
fi


