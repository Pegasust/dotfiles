# Ideally, this should contain the barebone necessary for building/interacting 
# with tech used in this project
#
# Should also incorporate shortcuts like scripts/{hm-switch,conf-sysnix}.sh in here instead
#
# It should not contain PDE
{pkgs? import <nixpkgs> {}
,lib
,...}: pkgs.mkShell {
  # mkShell doesn't care about the differences across nativeBuildInputs,
  # buildInputs, or packages
  buildInputs = [
    # shell scripts
    (lib.shellAsDrv {script = ''echo "hello world"''; pname = "hello";})
    # TODO: decompose hm-switch.sh with a base version (where HOME_MANAGER_BIN is injected)
    # (lib.shellAsDrv {script = builtins.readFile ./scripts/hm-switch.sh; pname = "hm-switch";})
  ];

  # env vars
  lol="hello world";
}

