{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./hardware-configuration.nix
    nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "nixos";
  system.stateVersion = "22.05";

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "nixos"; # if change defaultUser, make sure uid to be 1000 (first user)
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;

  };
  # users.users.<defaultUser>.uid = 1000;

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Home manager
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.git = {
    enable = true;
    # more information should be configured under user level
  };
  programs.zsh = {
  	enable = true;
	shellAliases = {
		# list lists
		ll = "ls -l";
		update = "sudo nixos-rebuild switch";
	};
	history = {
		size = 10000;
		path = "${config.xdg.dataHome}/zsh/history";
	};
  };

  environment.systemPackages = [
    pkgs.gnumake
  ];
}
