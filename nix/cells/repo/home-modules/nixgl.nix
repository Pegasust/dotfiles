{inputs, cell, namespace}: { pkgs, config, lib, ... }:
let
  cfg = config."${namespace}".graphics;
  cfgEnable = cfg.enable or (cfg.useNixGL.defaultPackage != null);
  types = lib.types;
in
{
  imports = [ ./shells.nix ];
  options."${namespace}".nixgl = {
    enable = lib.mkEnableOption "nixgl";
    useNixGL = {
      package = lib.mkPackageOption pkgs "nixGL package" {
        default = [
          "nixgl"
          "auto"
          "nixGLDefault"
        ];
      };
      defaultPackage = lib.mkOption {
        type = types.nullOr (types.enum [ "nixGLIntel" "nixGLNvidia" "nixGLNvidiaBumblebee" ]);
        description = "Which nixGL package to be aliased as `nixGL` on the shell";
        default = null;
        example = "nixGLIntel";
      };
    };
  };
  # NOTE: importing shells does not mean we're enabling everything, if we do mkDefault false
  # but the dilemma is, if the user import BOTH graphics.nix and shells.nix
  # they will also need to do `config."${namespace}".shells.enable`
  # generally, we want the behavior: import means enable
  config = lib.mkIf cfgEnable {
    "${namespace}".graphics._enable = lib.mkForce true;
    "${namespace}".shells = {
      shellAliases = lib.mkIf (cfg.useNixGL.defaultPackage != null) {
        nixGL = cfg.useNixGL.defaultPackage;
      };
    };
    home.packages = [ cfg.useNixGL.package ];
  };
}
