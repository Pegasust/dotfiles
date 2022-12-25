# Ideally, this should contain the barebone necessary for building/interacting 
# with tech used in this project

# Should also incorporate shortcuts like scripts/{hm-switch,conf-sysnix}.sh in here instead

# It should not contain PDE
{pkgs? import <nixpkgs> {}
,lib
,...}: pkgs.mkShell {
  # mkShell doesn't care about the differences across nativeBuildInputs,
  # buildInputs, or packages
  buildInputs = [
    # shell scripts
    (lib.shellAsDrv {script = ''echo "hello world"''; pname = "hello";})
  ];

  # env vars
  lol="hello world";
}

