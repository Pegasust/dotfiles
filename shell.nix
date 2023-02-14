# This uses the exported devShells from flake.nix
# the default or base version of nix-shell can be found in dev-shell.nix instead
# This architecture is because we use top-level flake.nix
(import
  (
    let 
      lock = builtins.fromJSON (builtins.readFile ./flake.lock); 
    in (import ./c_.nix).fetchTree lock.nodes.flake-compat.locked
  )
  { src = ./.; }
).shellNix
