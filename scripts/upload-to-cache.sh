#!/bin/sh

set -eu
set -f # disable globbing (/nix/store may contain glob chars)
export IFS=' '

# $OUT_PATHS when invoked by nix.settings.post-build-hook will be
# space-separated paths to /nix/store/
echo "Uploading paths" $OUT_PATHS
exec nix copy --to "s3://example-nix-cache" $OUT_PATHS

