{
  description = "simple home-manager config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {nixpkgs, home-manager, ...}:
    let system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
      modules = [./home.nix];
      };
    };
}
