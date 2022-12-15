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
    naersk.url = "gihub:nix-community/naersk";
  };
  outputs = { nixpkgs, ... } @ inputs:
    let
      # init config
      overlays = [ nixgl.overlay rust-overlay.overlays.default ];
      pkgs = import nixpkgs { inherit overlays; };
      _lib = pkgs.lib;
      lib = _lib.recursiveUpdate _lib import ./lib { inherit pkgs; };

      # module collecting
      hosts = import ./hosts { inherit pkgs lib; };
      users = import ./users { inherit pkgs lib; };
    in
    {
      inherit pkgs lib overlays;
      nixosConfigurations = hosts;
      homeConfigurations = users;
    };
}
