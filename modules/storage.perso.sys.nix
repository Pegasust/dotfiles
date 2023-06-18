# Personal configuration on storage solution
{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = [
    pkgs.s3fs
    pkgs.cifs-utils
  ];

  # Sadly, autofs uses systemd, so we can't put it in home-manager
  # HACK: need to store secret somewhere so that root can access this
  # because autofs may run as root for now, we enforce putting the secret in this monorepo
  # TODO: make this configuration nix-less to show that it's 100% data
  services.autofs = let
    # confToBackendArg {lol="what"; empty=""; name_only=null;} -> "lol=what,empty=,name_only"
    # TODO: change null -> true/false. This allows overriding & better self-documentation
    confToBackendArg = conf: (lib.concatStringsSep ","
      (lib.mapAttrsToList (name: value: "${name}${lib.optionalString (value != null) "=${value}"}") conf));

    # mount_dest: path ("wow")
    # backend_args: nix attrs representing the arguments to be passed to s3fs
    #    ({"-fstype" = "fuse"; "use_cache" = "/tmp";})
    # bucket: bucket name (hungtr-hot)
    #     NOTE: s3 custom provider will be provided inside
    #    backend_args, so just put the bucket name here
    #
    #-> "${mount_dest} ${formatted_args} ${s3fs-bin}#${bucket}"
    autofs-s3fs_entry = {
      mount_dest,
      backend_args ? {"-fstype" = "fuse";},
      bucket,
    } @ inputs: let
      s3fs-exec = "${pkgs.s3fs}/bin/s3fs";
    in "${mount_dest} ${confToBackendArg backend_args} :${s3fs-exec}\#${bucket}";
    personalStorage = [
      (autofs-s3fs_entry {
        mount_dest = "garden";
        backend_args = {
          "-fstype" = "fuse";
          use_cache = "/tmp";
          del_cache = null;
          allow_other = null;
          url = "https://v5h5.la11.idrivee2-14.com";
          passwd_file = config.age.secrets."s3fs.digital-garden".path;
          dbglevel = "debug"; # enable this for better debugging info in journalctl
          uid = "1000"; # default user
          gid = "100"; # users
          umask = "003"; # others read only, fully shared for users group
        };
        bucket = "digital-garden";
      })
      (
        let
          args = {
            "-fstype" = "cifs";
            credentials = config.age.secrets._nhitrl_cred.path;
            user = null;
            uid = "1001";
            gid = "100";
            dir_mode = "0777";
            file_mode = "0777";
          };
        in "felia_d ${confToBackendArg args} ://felia.coati-celsius.ts.net/d"
      )
      (
        let
          args = {
            "-fstype" = "cifs";
            credentials = config.age.secrets._nhitrl_cred.path;
            user = null;
            uid = "1001";
            gid = "100";
            dir_mode = "0777";
            file_mode = "0777";
          };
        in "felia_f ${confToBackendArg args} ://felia.coati-celsius.ts.net/f"
      )
    ];
    persoConf = pkgs.writeText "auto.personal" (builtins.concatStringsSep "\n" personalStorage);
  in {
    enable = true;
    # Creates /perso directory with every subdirectory declared by ${personalStorage}
    # as of now (might be stale), /perso/hot is the only mount accessible
    # that is also managed by s3fs
    autoMaster = ''
      /perso file:${persoConf}
    '';
    timeout = 30; # default: 600, 600 seconds (10 mins) of inactivity => unmount
    # debug = true; # writes to more to journalctl
  };
}
