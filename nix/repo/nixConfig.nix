{
  inputs,
  cell,
}: let
  # decorator for now, for data collecting :)
  nix-conf = a: a;
in {
  "htran@mbp" = nix-conf ''
    accept-flake-config = true
    experimental-features = nix-command flakes
    post-build-hook = /etc/nix/upload-to-cache.sh
    trusted-users = root htran hungtran hwtr
    max-jobs = 8
    cores = 12
    # default is true for Linux, false for every one else
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-sandbox
    sandbox = true
  '';
  "hungtran@mba-m2" = nix-conf ''
    accept-flake-config = true
    experimental-features = nix-command flakes
    post-build-hook = /etc/nix/upload-to-cache.sh
    trusted-users = root htran hungtran hwtr
    max-jobs = 7
    cores = 8
    # default is true for Linux, false for every one else
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-sandbox
    sandbox = true
  '';
}
