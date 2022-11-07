#!/usr/bin/env sh
# This is used when we need to refresh hardware-configuration.nix
# Basically what this does is to mount the drives, then ask nixos-generate-config
# to regenerate hardware-configuration.nix for us.
# Manual on nixos-generate-config [here](https://www.mankier.com/8/nixos-generate-config)
SCRIPT_DIR=$(realpath $(dirname $0))
${SCRIPT_DIR}/felia-mount.sh
sudo nixos-generate-config
