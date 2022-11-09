{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    from-yaml ={
      url = "github:pegasust/fromYaml";
      flake = false;
    };
  };
  outputs = {nixpkgs,from-yaml, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    lib = {
        fromYaml = import "${from-yaml}/fromYaml.nix" {lib = pkgs.lib;};
    };
  in {
    inherit nixpkgs;
    inherit from-yaml;
    inherit lib;
    fromYamlFn = lib.fromYaml;
  };
}

