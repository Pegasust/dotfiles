{ config
, proj_root
, myLib
, ...
}:
let
  inherit (myLib) fromYaml;
  actualConfig = fromYaml (builtins.readFile "${proj_root}//alacritty/alacritty.yml");
  cfg = config.base.alacritty;
in
{
  options.base.alacritty.font.family = myLib.mkOption {
    type = myLib.types.singleLineStr;
    default = actualConfig.font.normal.family;
    description = ''
      The font family for Alacritty
    '';
    example = "DroidSansMono NF";
  };
  options.base.alacritty.enable = myLib.mkOption {
    type = myLib.types.bool;
    default = true;
    description = ''
      Enables alacritty
    '';
    example = true;
  };

  config.programs.alacritty = {
    enable = cfg.enable;
    settings = actualConfig // {
      font.normal.family = cfg.font.family;
    };
  };
}
