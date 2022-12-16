{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # useful only when packaging, not really within config zone
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nixgl.url = "github:guibou/nixGL";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # naersk.url = "gihub:nix-community/naersk";
  };
  outputs = { nixpkgs, nixgl, rust-overlay, flake-utils-plus, ... } @ inputs:
    {
      # HACK:
      # this is to get multiple platforms support for home-manager
      # see https://github.com/nix-community/home-manager/issues/3075#issuecomment-1330661815
      # Expect this to change quite in some near future
      # packages.linux_something.{nixosConfigurations,homeConfigurations}
      packages = builtins.foldl'
        (so_far: system: (
          let
            # init config
            overlays = [ nixgl.overlay rust-overlay.overlays.default ];
            pkgs = import nixpkgs { inherit system overlays; };
            _lib = pkgs.lib;
            lib = _lib.recursiveUpdate _lib import ./lib { inherit pkgs; };
            configModule = import ./configModule;
            moduleInputs = lib.recursiveUpdate inputs { inherit pkgs lib configModule; };

            # module collecting
            hosts = import ./hosts moduleInputs;
            users = import ./users moduleInputs;
            exportSystems = { nixosConfigurations, homeConfigurations }@_configs: {
              packages.${system} = {
                inherit (_configs) nixosConfigurations homeConfigurations;
              };
            };
          in
          so_far // {
            ${system} = {
              inherit pkgs lib overlays;
              nixosConfigurations = hosts;
              homeConfigurations = users;
            };
          }
        ))
        { }
        flake-utils-plus.lib.defaultSystems;
    };
}
