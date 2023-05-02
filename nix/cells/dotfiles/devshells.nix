{inputs, cells}: let 
  inherit (inputs) std nixpkgs;

in {
  default = std.lib.dev.mkShell {
    name = nixpkgs.lib.
  };
}
