{pkgs
,lib
,proj_root
}:{
  imports = [
    ./minimal.sys.nix
    ./mosh.sys.nix
    ./tailscale.sys.nix
  ];
}
