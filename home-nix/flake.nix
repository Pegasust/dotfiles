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
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, home-manager, nixgl, rust-overlay, flake-utils, ... }:
    let
      system = "x86_64-linux";
      overlays = [ nixgl.overlay rust-overlay.overlays.default ];
      # pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
      pkgs = import nixpkgs { inherit system overlays; };
      lib = (import ../lib-nix { inherit pkgs; lib = pkgs.lib; });
    in
    rec {
      inherit pkgs;
      inherit lib;
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        # optionally pass inarguments to module
        # we migrate this from in-place modules to allow flexibility
        # in this case, we can add "home" to input arglist of home.nix
        extraSpecialArgs = {
          inherit lib;
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
          # inherit lib;
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
          # inherit lib;
          myHome = {
            username = "hwtr";
            homeDirectory = "/home/hwtr";
            packages = [ pkgs.nixgl.nixGLIntel ];
            shellAliases = {
              nixGL = "nixGLIntel";
            };
          };
        };
      };
    };
}
