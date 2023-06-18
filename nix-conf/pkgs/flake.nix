{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "gihub:nix-community/naersk";
  };
  outputs = {
    nixpkgs,
    rust-overlay,
    naersk,
  }: let
    pkgs = import nixpkgs {overlays = [rust-overlay.overlays.default];};
    lib = pkgs.lib;
  in (import ./default.nix {inherit pkgs lib naersk;});
}
