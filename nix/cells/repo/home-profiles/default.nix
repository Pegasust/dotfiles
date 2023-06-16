_imports@{inputs, cell}: let 
  namespace = "repo";
  imports = _imports // {inherit namespace;};
in {
  neovim = import ./neovim.nix imports;
  nerd_font_module = {config, pkgs, ...}: {
    imports = [
      import inputs.cells."${namespace}"
    ];
    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    ];
    "${namespace}".alacritty.font.family = "Hack Nerd Font Mono";
  };

  secrets = {
    age.secrets.s3fs = {
      file = "${inputs.self}/secrets/s3fs.age";
      # mode = "600";  # owner + group only
      # owner = "hungtr";
      # group = "users";
    };
    age.secrets."s3fs.digital-garden" = {
      file = "${inputs.self}/secrets/s3fs.digital-garden.age";
    };
    age.secrets._nhitrl_cred = {
      file = "${inputs.self}/secrets/_nhitrl.age";
    };
    age.secrets."wifi.env" = {
      file = "${inputs.self}/secrets/wifi.env.age";
    };
  };

  ssh = {config, lib, ...}: let cfg = config."${namespace}".ssh; in {
    options."${namespace}".ssh.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables SSH
      '';
    };
    config.programs.ssh = {
      inherit (cfg) enable;
      forwardAgent = true;
      includes = ["${inputs.self}/native_configs/ssh/config"];
    };
  };

  alacritty = {config, lib,...}: let cfg = config."${namespace}".alacritty; in {
    imports = [
      import "${inputs.cells.repo.home-modules.alacritty}"
    ];
    configs."${namespace}".alacritty = {
      enable = true;
      config-file = "${inputs.self}//native-configs/alacritty/alacritty.yml";
    };
  };
}
