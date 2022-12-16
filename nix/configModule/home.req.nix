{ config, pkgs, lib, ... }@input:
let
  cfg = config.base.home;
  types = lib.types;
in
{
  options.base.home = {
    packages = lib.mkOption {
      type = types.listOf types.package;
      description = "Addtional packages that are available at user level";
      default = [ ];
      example = [ pkgs.python310Full pkgs.ripgrep ];
    };
    user = lib.mkOption {
      
    };
  };
}
