#!/usr/bin/env sh
## Configures a new nixos system to this repository
## Blame: Hung Tran (Pegasust) <pegasucksgg@gmail.com>

set -xv

HOSTNAME=${1}

if [ -z $HOSTNAME ]; then
	current_hostname=$(hostname)
	echo "Missing hostname as first param."
	echo "Type the hostname you want to be here"
	read -p "[${current_hostname}] > " HOSTNAME
	HOSTNAME=${HOSTNAME:-${current_hostname}}
	read -p "Using hostname: ${HOSTNAME}. Press ENTER to continue." _WHATEVER_
fi

# Where is this script located
SCRIPT_DIR=$(realpath $(dirname $0))
echo "SCRIPT_DIR: ${SCRIPT_DIR}"

SYSNIX_DIR="${SCRIPT_DIR}/../nix-conf/system"

# Copy hardware-configuration of existing machine onto our version control
SYSNIX_PROF="${SYSNIX_DIR}/profiles/${HOSTNAME}"
HARDWARE_CONF="${SYSNIX_PROF}/hardware-configuration.nix" 
if [ ! -f "${HARDWARE_CONF}" ]; then
	mkdir "$SYSNIX_PROF"
	sudo cp /etc/nixos/hardware-configuration.nix ${HARDWARE_CONF}
fi
git add "${HARDWARE_CONF}"

echo "Apply nixos-rebuild"
sudo nixos-rebuild switch --flake "${SYSNIX_DIR}#${HOSTNAME}"

