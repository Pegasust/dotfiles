{ config, proj_root, pkgs, lib, ... }:
let
  cfg = config.base.keepass;
  trimNull = lib.filterAttrsRecursive (name: value: value != null);
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
    path = lib.mkOption {
      type = lib.types.path;
      description = "Path to kdbx file";
      default = null;
      example = "/media/homelab/f/PersistentHotStorage/keepass.kdbx";
    };
    keyfile_path = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = ''
        Path to key file for the database
        If null, then the field is unset
      '';
      default = null;
      example = "/path/to/mykeyfile.key";
    };
    store_encrypted_password = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to store encrypted password for 24 hrs before re-prompt";
      default = true;
      example = "false";
    };
    copy_timeout_secs = lib.mkOption {
      type = lib.types.int;
      description = "Timeout (seconds) before the password is expired from clipboard";
      default = 12;
      example = "60";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kpcli-py # kp but is in cli
    ] ++ (if cfg.use_gui or config.base.graphics._enable then [
      pkgs.keepass # Personal secret management
    ] else [ ]);
    home.file.".kp/config.ini".text = lib.generators.toINI { } (trimNull {
      default = {
        KEEPASSDB = cfg.path;
        KEEPASSDB_KEYFILE = cfg.keyfile_path;
        STORE_ENCRYPTED_PASSWORD = cfg.store_encrypted_password;
        KEEPASSDB_PASSWORD = null; # No good way yet to store the password
        KEEPASSDB_TIMEOUT = cfg.copy_timeout_secs;
      };
    });
  };
}
