# Ideally, this should contain the barebone necessary for building/interacting 
# with tech used in this project

# Should also incorporate shortcuts like scripts/{hm-switch,conf-sysnix}.sh in here instead

# It should not contain PDE
{pkgs? import <nixpkgs> {}
,...}: pkgs.mkShell {
    # These are the ones that can be built by a remote machine
    nativeBuildInputs = [];
    # These are the ones that must be built by the target machine
    lol="hello world";
}

