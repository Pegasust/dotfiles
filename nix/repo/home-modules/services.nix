{
  inputs,
  cell,
}: {
  rclone-mount = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.rclone;
    rcloneCommand = "${pkgs.rclone}/bin/rclone";

    inherit (lib) mkEnableOption mkOption types mkIf mapAttrs' nameValuePair;
    makeMountService = name: mountCfg: {
      Unit = {
        Description = "Rclone Mount ${name}";
        After = ["network.target"];
      };

      Service = {
        ExecStart = "${rcloneCommand} mount ${mountCfg.remotePath} ${mountCfg.mountPoint}";
        Restart = "on-failure";
      };

      Install = {WantedBy = ["default.target"];};
    };

    makeLaunchdService = name: mountCfg: {
      enable = true;
      settings = {
        ProgramArguments = ["/bin/sh" "-c" "${rcloneCommand} mount ${mountCfg.remotePath} ${mountCfg.mountPoint}"];
        KeepAlive = {
          NetworkState = true;
        };
      };
    };
  in {
    options.services.rclone = {
      enable = mkEnableOption "rclone mount service";

      mounts = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            remotePath = mkOption {
              type = types.str;
              default = "";
              description = "The remote path to mount via rclone";
            };

            mountPoint = mkOption {
              type = types.str;
              default = "";
              description = "The local mount point for the rclone mount";
            };
          };
        });
        default = {};
        description = "Rclone mounts";
      };
    };

    config = mkIf cfg.enable {
      home.packages = [pkgs.rclone];

      systemd.user.services = mapAttrs' (n: v: nameValuePair "rclone-mount-${n}" (makeMountService n v)) cfg.mounts;

      launchd.user.agents = mapAttrs' (n: v: nameValuePair "rclone-mount-${n}" (makeLaunchdService n v)) cfg.mounts;
    };
  };
}
