# This uses the exported devShells from flake.nix
# the default or base version of nix-shell can be found in dev-shell.nix instead
# This architecture is because we use top-level flake.nix
(import
  (
    let lock = builtins.fromJSON (builtins.readFile ./flake.lock); in
    fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    }
  )
  { src = ./.; }
).shellNix
