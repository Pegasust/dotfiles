{ config
, proj_root
, myLib
,  ...
}:
let cfg = config.base.ssh;
in
{
  options.base.ssh.enable = myLib.mkOption {
    type = myLib.types.bool;
    default = true;
    example = false;
    description = ''
      Enables SSH
    '';
  };
  config.programs.ssh = {
    inherit (cfg) enable;
    forwardAgent = true;
    extraConfig = builtins.readFile "${proj_root.config.path}/ssh/config";
  };
}

