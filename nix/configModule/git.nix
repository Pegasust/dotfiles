{ config
, myLib
, ...
}:
let
  cfg = config.base.git;
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
in
{
  options.base.git = {
    aliases = myLib.mkOption {
      type = myLib.types.attrs;
      default = { };
      example = baseAliases;
      description = ''
        Additional git aliases. This settings comes with base configuration.
        Redeclaring the base config will override the values.
      ''; # TODO: Add baseAliases as string here (builtins.toString doesn't work)
    };
    name = myLib.mkOption {
      type = myLib.types.str;
      default = "Pegasust";
      description = "Git username that appears on commits";
      example = "Pegasust";
    };
    email = myLib.mkOption {
      type = myLib.types.str;
      default = "pegasucksgg@gmail.com";
      example = "peagsucksgg@gmail.com";
      description = "Git email that appears on commits";
    };
    ignores = myLib.mkOption {
      type = myLib.types.listOf myLib.types.str;
      default = [
        ".vscode" # vscode settings
        ".direnv" # .envrc cached outputs
      ];
      description = ''
        .gitignore patterns that are applied in every repository.
        This is useful for IDE-specific settings.
      '';
      example = [ ".direnv" "node_modules" ];
    };
    enable = myLib.mkOption {
      type = myLib.types.bool;
      default = true;
      description = ''
        Enables git
      '';
      example = false;
    };
    credentialCacheTimeoutSeconds = myLib.mkOption {
      type = myLib.types.int;
      default = 3000;
      description = "Credential cache (in-memory store) for Git in seconds.";
      example = 3000;
    };
  };
  # TODO : anyway to override configuration?
  config.programs.git = lib.mkIf cfg.enable {
    inherit (cfg) ignores;
    enable = true;
    userName = cfg.name;
    userEmail = cfg.email;
    aliases = baseAliases // cfg.aliases;
    extraConfig = {
      credential.helper = "cache --timeout=${builtins.toString cfg.credentialCacheTimeoutSeconds}";
    };
    lfs.enable = true;
  };
}
