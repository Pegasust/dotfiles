{ pkgs
, config
, lib
, ...
}: let cfg = config.mod.tailscale; in {
  options.mod.tailscale = { 
    enable = lib.mkEnableOption "tailscale";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tailscale ];
    services.tailscale.enable = true;

    systemd.services.tailscale-autoconnect = {
      description = "Automatically connects to Tailscale";

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

    networking.firewall = lib.mkIf config.networking.firewall.enable {
      trustedInterfaces = [
        "tailscale0"
      ];
      allowedUDPPorts = [
        config.services.tailscale.port
      ];
      allowedTCPPorts = [
        22
      ];
      checkReversePath = "loose";
    };
  };
}
