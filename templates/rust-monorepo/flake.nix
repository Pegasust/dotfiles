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
          ];
          shellHook = ''
            # nix flake update # is this even needed?
          '';
        };
      });
}
