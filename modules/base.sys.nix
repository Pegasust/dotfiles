{ pkgs
, lib
, proj_root
, ...
}: {
  imports = [
    ./minimal.sys.nix
    ./mosh.sys.nix
    ./tailscale.sys.nix
    ./ssh.sys.nix
  ];
  environment.systemPackages = [ pkgs.lm_sensors ];
  time.timeZone = "America/Phoenix";

}
