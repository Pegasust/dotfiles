# Ideally, this should contain the barebone necessary for building/interacting 
# with tech used in this project
#
# Should also incorporate shortcuts like scripts/{hm-switch,conf-sysnix}.sh in here instead
#
# It should not contain PDE
{ pkgs ? import <nixpkgs> { }
, lib
, ...
}: pkgs.mkShell {
  # mkShell doesn't care about the differences across nativeBuildInputs,
  # buildInputs, or packages
  buildInputs = [
    # shell scripts
    pkgs.rust4cargo
    pkgs.sops
  ];

  shellHook = ''
  # Since we need late dispatch of ~, we have to put this in shellHook.
  export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
  '';
  # env vars
  lol = "hello world";
}

