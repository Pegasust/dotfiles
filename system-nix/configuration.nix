{ lib, pkgs, config, modulesPath, specialArgs, ... }:
let
  hostname = specialArgs.hostname;
  enableSSH = specialArgs.enableSSH or true;
  networking = { hostName = hostname; } // (specialArgs.networking or { });
  boot = specialArgs.boot or { };
  services = specialArgs.services or { };
  includeHardware = specialArgs.includeHardware or true;
in
with lib;
{
  imports = (if includeHardware then [
    ./profiles/${hostname}/hardware-configuration.nix
  ] else [ ]) ++ [
    "${modulesPath}/profiles/minimal.nix"
  ];
  inherit networking;
  inherit boot;
  inherit services;

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

  # Some basic programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    # more information should be configured under user level
    # See other config at @/home-nix
  };

  environment.systemPackages = [
    pkgs.gnumake
    pkgs.wget
    pkgs.inetutils # network diag
    pkgs.mtr     # network diag
    pkgs.sysstat # sys diag
    pkgs.mosh    # ssh-alt; parsec-like
    pkgs.tailscale # VPC
  ];
}

