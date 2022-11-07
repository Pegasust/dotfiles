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
        username = "nixos";
        homeDirectory = "/home/nixos";
        modules = [./home.nix];
      };
      homeConfigurations.ubuntu_admin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        username = "ubuntu_admin";
        homeDirectory = "/home/ubuntu_admin";
        modules = [./home.nix];
      };
      homeConfigurations.hwtr = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        username = "hwtr";
        homeDirectory = "/home/hwtr";
        modules = [./home.nix];
      };
    };
}
