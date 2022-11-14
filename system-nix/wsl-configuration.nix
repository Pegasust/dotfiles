{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    ./hardware-configuration.nix
    nixos-wsl.nixosModules.wsl
    configuration.nix
  ];

  system.stateVersion = "22.05";

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "nixos"; # if change defaultUser, make sure uid to be 1000 (first user)
    startMenuLaunchers = true;
    automountOptions = "drvfs,metadata,uid=1000,gid=100";
    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;

  };
  # users.users.<defaultUser>.uid = 1000;
  # networking.hostName = "nixos";

}
