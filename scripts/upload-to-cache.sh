#!/usr/bin/env sh
# set -eux
# set -f # disable globbing (/nix/store may contain glob chars)
# export IFS=' '
# PATH=/nix/var/nix/profiles/default/bin:$PATH
#
# # $OUT_PATHS when invoked by nix.settings.post-build-hook will be
# # space-separated paths to /nix/store/
# echo "Uploading paths" $OUT_PATHS
# nix copy --to "ssh-ng://10.100.200.230" $OUT_PATHS

