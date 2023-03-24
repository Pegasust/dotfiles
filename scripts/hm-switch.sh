#!/usr/bin/env sh
# NOTE: Untested on case of no home-manager
set -xveu
# Where this script located
SCRIPT_DIR=$(readlink -f $(dirname $0))
echo "SCRIPT_DIR: ${SCRIPT_DIR}"

HOME_MANAGER_DIR="${SCRIPT_DIR}/../nix-conf/home-manager"

# Manage nix.conf. Ideally, this should be done with snapshot-based version
# and with preview on-the-spot, with some timeout (like deploy-rs)
if [ -f /etc/nix/nix.conf ]; then
    # managed nix.conf
    BACKUP_FILE="/etc/nix/nix.conf.backup"
    echo "overwriting /etc/nix/nix.conf. Please find latest backup in ${BACKUP_FILE}"
    sudo cp /etc/nix/nix.conf ${BACKUP_FILE}
fi
sudo cp "${HOME_MANAGER_DIR}/hwtr/nix.conf" /etc/nix/
sudo cp "${SCRIPT_DIR}/upload-to-cache.sh" /etc/nix/
sudo chmod +x /etc/nix/*.sh
# Reload nix daemon so that new changes are applied.
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon

# Mason is bad: it puts binaries onto xdg.data
# let's make mason starts fresh, just in case we introduce RPATH hacks 
# that injects binary for Mason to use.
sudo rm -rf ~/.local/share/nvim/mason

# NOTE: https://discourse.nixos.org/t/relative-path-support-for-nix-flakes/18795
# nix flake update is required for relative paths to work
nix flake update
nix flake update "${SCRIPT_DIR}/../nix-conf/home-manager"
# test if we have home-manager, if not, attempt to use nix to put home-manager to
# our environment
if ! command -v home-manager ; then
    nix-shell -p home-manager --run "home-manager switch --flake $HOME_MANAGER_DIR $@"
else
    home-manager switch -b backup --flake "$HOME_MANAGER_DIR" $@
fi


# Attempt to reload running instances
tmux source-file ~/.config/tmux/tmux.conf

