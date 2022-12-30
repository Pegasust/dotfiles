{ config, proj_root, pkgs, lib, ... }:
let
  cfg = config.base.keepass;
in
{
  imports = [ ./graphics.nix ];
  options.base.keepass = {
    enable = lib.mkEnableOption "keepass";
    use_gui = lib.mkOption {
      type = lib.types.bool;
      description = "wheter to enable keepass GUI (the original one)";
      default = false;
      example = "true";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kpcli # kp but is in cli
    ] ++ (if cfg.use_gui or config.base.graphics._enable then [
      pkgs.keepass # Personal secret management
    ] else [ ]);
    # xdg.dataFile."keepass.kdbx".path = 
  };
}
