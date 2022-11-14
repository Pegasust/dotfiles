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
  ];
}
