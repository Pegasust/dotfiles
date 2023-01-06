{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, utils, naersk, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs { inherit system overlays; };
        rust_pkgs = (pkgs.rust-bin.selectLatestNightlyWith
          (
            toolchain:
            toolchain.default.override {
              extensions = [ "rust-src" "rust-analyzer" "rust-docs" "clippy" "miri" ];
            }
          ));
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShell = with pkgs; mkShell {
          buildInputs = [
            rust_pkgs
            # rust's compiler is quite powerful enough to the point where
            # a REPL is not really necessary.
            # Rely on the compiler and bacon 99% of the time
            # only use REPL if you need to explore/prototype
            # In that case, might as well put the code into sandbox
            pkgs.evcxr
            pkgs.bacon
          ];
          shellHook = ''
            # nix flake update # is this even needed?
          '';
        };
      });
}
