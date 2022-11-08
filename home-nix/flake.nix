{
  description = "simple home-manager config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:guibou/nixGL";
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [nixgl.overlay];
    in
    {
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        # optionally pass inarguments to module
        # we migrate this from in-place modules to allow flexibility
        # in this case, we can add "home" to input arglist of home.nix
        extraSpecialArgs = {
          myHome = {
            username = "nixos";
            homeDirectory = "/home/nixos";
          };
        };
      };
      homeConfigurations.ubuntu_admin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          myHome = {
            username = "ubuntu_admin";
            homeDirectory = "/home/ubuntu_admin";
          };
        };
      };
      homeConfigurations.hwtr = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          myHome = {
            username = "hwtr";
            homeDirectory = "/home/hwtr";
            packages = [pkgs.nixgl.nixGLIntel];
            shellAliases = {
              nixGL = "nixGLIntel";
            };
          };
        };
      };
    };
}
