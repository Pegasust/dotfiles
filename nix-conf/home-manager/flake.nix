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
    from-yaml = {
      url = "github:pegasust/fromYaml";
      flake = false;
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nixgl
    , rust-overlay
    , flake-utils
    , from-yaml
    , ...
    }:
    let
      system = "x86_64-linux";
      overlays = [ nixgl.overlay rust-overlay.overlays.default ];
      # pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
      pkgs = import nixpkgs {
        inherit system overlays;
        config = { allowUnfree = true; };
      };
      lib = (import ../lib-nix { inherit pkgs from-yaml; lib = pkgs.lib; });
    in
    {
      homeConfigurations =
        let x11_wsl = ''
          # x11 output for WSL
          export DISPLAY=$(ip route list default | awk '{print $3}'):0
          export LIBGL_ALWAYS_INDIRECT=1
        '';
        in
        rec {
          "hungtr" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
            ];
            # optionally pass inarguments to module
            # we migrate this from in-place modules to allow flexibility
            # in this case, we can add "home" to input arglist of home.nix
            extraSpecialArgs = {
              myLib = lib;
              myHome = {
                username = "hungtr";
                homeDirectory = "/home/hungtr";
              };
            };
          };
          "nixos@Felia" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
            ];
            # optionally pass inarguments to module
            # we migrate this from in-place modules to allow flexibility
            # in this case, we can add "home" to input arglist of home.nix
            extraSpecialArgs = {
              myLib = lib;
              myHome = {
                username = "nixos";
                homeDirectory = "/home/nixos";
                shellInitExtra = ''
                '' + x11_wsl;
              };
            };
          };
          # NOTE: This is never actually tested. This is for Ubuntu@Felia
          # "ubuntu_admin" = home-manager.lib.homeManagerConfiguration {
          #   inherit pkgs;
          #   modules = [
          #     ./home.nix
          #   ];
          #   extraSpecialArgs = {
          #     myLib = lib;
          #     myHome = {
          #       username = "ubuntu_admin";
          #       homeDirectory = "/home/ubuntu_admin";
          #       shellInitExtra = ''
          #       '' + x11_wsl;
          #     };
          #   };
          # };

          # Personal laptop
          hwtr = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
            ];
            extraSpecialArgs = {
              myLib = lib;
              myHome = {
                username = "hwtr";
                homeDirectory = "/home/hwtr";
                packages = [
                  pkgs.nixgl.nixGLIntel
                  pkgs.postman
                ];
                shellAliases = {
                  nixGL = "nixGLIntel";
                };
              };
            };
          };
        };
    };
}
