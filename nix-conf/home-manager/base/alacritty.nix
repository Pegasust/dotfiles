{ config
, proj_root
, myLib
, ...
}:
let
  inherit (myLib) fromYaml;
  actualConfig = fromYaml (builtins.readFile "${proj_root.config.path}//alacritty/alacritty.yml");
  cfg = config.base.alacritty;
in
{
  options.base.alacritty =
    {
      font.family = myLib.mkOption {
        type = myLib.types.singleLineStr;
        default = actualConfig.font.normal.family;
        description = ''
          The font family for Alacritty
        '';
        example = "DroidSansMono NF";
      };
      enable = myLib.mkOption {
        type = myLib.types.bool;
        default = true;
        description = ''
          Enables alacritty
        '';
        example = true;
      };
      _actualConfig = myLib.mkOption {
        type = myLib.types.attrs;
        visible = false;
        default = actualConfig;
        description = "underlying default config";
      };
      additionalConfigPath = myLib.mkOption {
        type = myLib.types.nullOr myLib.types.path;
        visible = false;
        default = null;
        description = "impurely write our alacritty.yml to this path";
      };
    };

  config.programs.alacritty = {
    enable = cfg.enable;
    settings = myLib.recursiveUpdate actualConfig {
      font.normal.family = cfg.font.family;
    };
  };
}
