{ config, proj_root, pkgs, lib, ... }:
let
  cfg = config.base.keepass;
in
{
  options.base.keepass = {
    
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kpcli # kp but is in cli
    ] ++ (if cfg.use_gui or config.base.has_gui then [
      pkgs.keepass # Personal secret management
    ] else [ ]);
    xdg.dataFile."keepass.kdbx".path = 
  };
}
