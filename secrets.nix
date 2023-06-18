# WARNING: currently not usable anymore
let
  inherit
    ((
        import
        (
          let
            lock = builtins.fromJSON (builtins.readFile ./flake.lock);
          in
            fetchTarball {
              url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
              sha256 = lock.nodes.flake-compat.locked.narHash;
            }
        )
        {src = ./.;}
      )
      .defaultNix)
    secrets
    ;
  inherit (secrets) pubKeys;
  inherit (pubKeys) users hosts;
  all = users // hosts;
  c_ = builtins;
in {
  "secrets/s3fs.age".publicKeys = c_.attrValues all;
  "secrets/s3fs.digital-garden.age".publicKeys = c_.attrValues all;
  "secrets/_nhitrl.age".publicKeys = c_.attrValues all;
  "secrets/wifi.env.age".publicKeys = c_.attrValues all;
}
