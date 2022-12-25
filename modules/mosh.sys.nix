{pkgs
,lib
,config
}: {
  environment.systemPackages = [pkgs.mosh];
  networking.firewall = lib.mkIf config.networking.firewall.enable {
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };
}

