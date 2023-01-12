#!/usr/bin/env sh
# NOTE: Untested on case of no home-manager
set -xv
# Where this script located
SCRIPT_DIR=$(realpath $(dirname $0))
echo "SCRIPT_DIR: ${SCRIPT_DIR}"

HOME_MANAGER_DIR="${SCRIPT_DIR}/../nix-conf/home-manager"

# Mason is bad: it puts binaries onto xdg.data
rm -rf ~/.local/share/nvim/mason

# test if we have home-manager, if not, attempt to use nix to put home-manager to
# our environment
if [ $(home-manager >/dev/null 2>&1) ]; then
    # highly likely we don't even have nix support to start with, so let's fix that
    sudo mv /etc/
    nix-shell -p home-manager --run "home-manager switch --flake $HOME_MANAGER_DIR"
else
    home-manager switch -b backup --flake "$HOME_MANAGER_DIR"
fi


