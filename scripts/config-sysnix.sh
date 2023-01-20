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

SYSNIX_DIR="${SCRIPT_DIR}/.."

# Copy hardware-configuration of existing machine onto our version control
SYSNIX_PROF="${SYSNIX_DIR}/hosts/${HOSTNAME}"
HARDWARE_CONF="${SYSNIX_PROF}/hardware-configuration.nix" 
if [ ! -f "${HARDWARE_CONF}" ]; then
	mkdir "$SYSNIX_PROF"
	sudo cp /etc/nixos/hardware-configuration.nix ${HARDWARE_CONF}
fi
git add "${HARDWARE_CONF}"

# Copy ssh/id-rsa details onto ssh/authorized_keys
SSH_PRIV="${HOME}/.ssh/id_rsa"
SSH_PUB="${SSH_PRIV}.pub"
SSH_DIR="${SCRIPT_DIR}/../native_configs/ssh"
if [ ! -f "${SSH_PRIV}" ]; then
	ssh-keygen -b 2048 -t rsa -f "${SSH_PRIV}" -q -N ""
fi
# idempotently adds to authorized_keys
cat "${SSH_PUB}" >> "${SSH_DIR}/authorized_keys"
# sort "${SSH_DIR}/authorized_keys" | uniq >"${SSH_DIR}/authorized_keys"
# NOTE: if we do sort... file >file, the ">file" is performed first, which truncates
# the file before we open to read. Hence, `sort [...] file >file` yields empty file.
# Because of this, we have to use `-o`
sort -u "${SSH_DIR}/authorized_keys" -o "${SSH_DIR}/authorized_keys"

echo "Apply nixos-rebuild"
sudo nixos-rebuild switch --flake "${SYSNIX_DIR}/nix-conf/system#${HOSTNAME}"

