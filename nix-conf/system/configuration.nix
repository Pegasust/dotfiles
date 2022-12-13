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
    ./profiles/${hostname}/hardware-configuration.nix
  ] else [ ]) ++ [
    "${modulesPath}/profiles/minimal.nix"
  ];
  boot = _boot;

# prune old builds
  nix.settings.auto-optimise-store = true;

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
  };
  users.users.root = {
    # openssh runs in root, no? This is because port < 1024 requires root.
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile "${proj_root}/ssh/authorized_keys");
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
  services = lib.recursiveUpdate _services {
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
      sleep 2
      # check if we are already authenticated to tailscale
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # ${pkgs.tailscale}/bin/tailscale up # blocks, doesn't give url
      # This time, configure device auth so that we authenticate from portal
      # https://tailscale.com/kb/1099/device-authorization/#enable-device-authorization-for-your-network 
      ${pkgs.tailscale}/bin/tailscale up -authkey tskey-auth-kJcgTG5CNTRL-PUVFkk31z1bThHpfq3FC5b1jcMmkW2EYW
    '';
  };
  # Don't touch networking.firewall.enable, just configure everything else.
  # inherit networking;
  # inherit _networking;
  networking = lib.recursiveUpdate _networking {
    firewall =
      if _networking ? firewall.enable && _networking.firewall.enable then {
        trustedInterfaces = _networking.firewall.trustedInterfaces or [ ] ++ [
          "tailscale0"
        ];
        allowedUDPPorts = _networking.firewall.allowedUDPPorts or [ ] ++ [
          config.services.tailscale.port
        ];
        allowedTCPPorts = _networking.firewall.allowedTCPPorts or [ ] ++ [
          22
        ];
        allowedUDPPortRanges = _networking.firewall.allowedUDPPortRanges or [ ] ++ [
          { from = 60000; to = 61000; } # mosh

        ];
        checkReversePath = "loose";
      } else { enable = false; };
  };

}

