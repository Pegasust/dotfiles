{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ { self, flake-utils, nixpkgs, home-manager, ... }: 
    let 
    nixpkgsOfSys = system: import nixpkgs { inherit system; };
    in flake-utils.lib.eachDefaultSystem (sys:
    {
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        system = sys;
	# configuration = import ./home.nix;
	modules = [./home.nix];
	pkgs = nixpkgs.legacyPackages.${sys};
      };

    }
  );
}
