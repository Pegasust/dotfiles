{ lib, pkgs, config, modulesPath, specialArgs, ... }:
let
  hostname = specialArgs.hostname;
  enableSSH = specialArgs.enableSSH or true;
  _networking = lib.recursiveUpdate { hostName = hostname; } (specialArgs._networking or { });
  _boot = specialArgs._boot or { };
  _services = specialArgs._services or { };
  includeHardware = specialArgs.includeHardware or true;
  proj_root = builtins.toString ./../..;
in
with lib;
{
  imports = (if includeHardware then [
    "${proj_root}/hosts/${hostname}/hardware-configuration.nix"
  ] else [ ]) ++ [
    "${modulesPath}/profiles/minimal.nix"
    "${proj_root}/modules/tailscale.sys.nix"
    "${proj_root}/modules/mosh.sys.nix"
  ];
  boot = _boot;

  # prune old builds
  nix.settings.auto-optimise-store = true;

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  users.users.hungtr = {
    isNormalUser = true;
    home = "/home/hungtr";
    description = "pegasust/hungtr";
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };
  users.users.root = {
    # openssh runs in root, no? This is because port < 1024 requires root.
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile "${proj_root}/native_configs/ssh/authorized_keys");
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
    pkgs.mtr # network diag
    pkgs.sysstat # sys diag
  ];
}

