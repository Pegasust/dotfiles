{ lib, pkgs, config, modulesPath, ... }:
with lib;
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    "${modulesPath}/profiles/minimal.nix"
  ];

  system.stateVersion = "22.05";
  # users.users.<defaultUser>.uid = 1000;
  # networking.hostName = "nixos";

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  users.users.hungtr = {
    isNormalUser = true;
    home = "/home/hungtr";
    description = "pegasust/hungtr";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ../ssh/authorized_keys);
  };

  # Let's just open ssh server in general, even though it may not be
  # network-accessible
  services.openssh = {
    permitRootLogin = "no";
    enable = true;
  };

  # Some basic programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    # more information should be configured under user level
  };

  environment.systemPackages = [
    pkgs.gnumake
    pkgs.wget
    pkgs.inetutils
    pkgs.mtr
    pkgs.sysstat
  ];
}

