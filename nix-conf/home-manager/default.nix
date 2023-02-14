# We use top-level nix-flake, so default.nix is basically just a wrapper around ./flake.nix
(import
  (
    let 
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      c_ = import ./../../c_.nix;
    in
    c_.fetchTree lock.nodes.flake-compat.locked
  )
  { src = ./.; }
).defaultNix
