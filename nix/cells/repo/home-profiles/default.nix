# This creates a layer that is specific to some profiles, but may require
# some variants in environment like username/email, work-oriented or personal
# and many more
_imports @ {
  inputs,
  cell,
}: let
  # TODO: I don't think abstracting namespace away is a good idea in this case
  namespace = "repo";
  imports = _imports // {inherit namespace;};
in {
  neovim = import ./neovim.nix imports;
  nerd_font_module = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      import
      inputs.cells."${namespace}"
    ];
    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override {fonts = ["Hack"];})
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

  ssh = {
    config,
    lib,
    ...
  }: let
    cfg = config."${namespace}".ssh;
  in {
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

  alacritty = {
    config,
    lib,
    ...
  }: let
    cfg = config."${namespace}".alacritty;
  in {
    imports = [
      import
      "${inputs.cells.repo.home-modules.alacritty}"
    ];
    configs."${namespace}".alacritty = {
      enable = true;
      config-path = "${inputs.self}//native-configs/alacritty/alacritty.yml";
      font.size = 11.0;
      font.family = "Hack Nerd Font Mono";
    };
  };

  shells = import ./shells.nix imports;

  git = {
    config,
    pkgs,
    lib,
    ...
  }: let
    baseAliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      sts = "status";
      co = "checkout";
      b = "branch";
    };
  in {
    options."${namespace}".git = {
      aliases = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        example = baseAliases;
        description = ''
          Additional git aliases. This config is merged on top of base aliases.
        '';
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Pegasust";
        description = "Git username that appears on commits";
        example = "Pegasust";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "pegasucksgg@gmail.com";
        example = "peagsucksgg@gmail.com";
        description = "Git email that appears on commits";
      };
      ignores = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".vscode" # vscode settings
          ".direnv" # .envrc cached outputs
          ".DS_Store" # MacOS users, amrite
        ];
        description = ''
          .gitignore patterns that are applied in every repository.
          This is useful for IDE-specific or environment-specific settings.
        '';
        example = [".direnv" "node_modules"];
      };
    };
  };
}
