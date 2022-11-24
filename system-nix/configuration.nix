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
  inherit boot;

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
    pkgs.mtr # network diag
    pkgs.sysstat # sys diag
    pkgs.mosh # ssh-alt; parsec-like
    pkgs.tailscale # VPC
  ];
  # tailscale is mandatory : ^)
  # inherit services;
  services = services // {
    tailscale.enable = true;
  };
  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = ''
      # wait for tailscaled to settle
      sleep 5
      # check if we are already authenticated to tailscale
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi
      # otherwise authenticate with tailscale
      ${pkgs.tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
    '';
  };
  # Don't touch networking.firewall.enable, just configure everything else.
  # inherit networking;
  networking = networking // {
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

}

