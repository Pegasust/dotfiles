{ pkgs
, lib
, config
, ...
}:
let cfg = config.mod.mosh; in
{
  options.mod.mosh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "enable mosh";
      default = true;
      example = false;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mosh ];
    networking.firewall = lib.mkIf config.networking.firewall.enable {
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
      ];
    };
  };
}

