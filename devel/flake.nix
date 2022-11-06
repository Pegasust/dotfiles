{
  description = "My development flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { 
    self, # instance of self
    nixpkgs, # nixpkgs flake
    flake-utils, 
    home-manager,
    ... 
  }: flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
            devShells.default = import ./shell.nix {
	       inherit pkgs;
	       inherit home-manager;
	    };
      }
    );
}
