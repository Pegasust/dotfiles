{
  description = "simple home-manager config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "./../../out-of-tree/nixGL";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nixgl
    , rust-overlay
    , flake-utils
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
      # lib = (import ../lib { inherit pkgs; lib = pkgs.lib; });
      base = import ./base;
      inherit (base) mkModuleArgs;
      
      kde_module = {config, pkgs, ...}: {
        fonts.fontconfig.enable = true;
        home.packages = [
          (pkgs.nerdfonts.override {fonts = ["DroidSansMono"];})
        ];
        # For some reasons, Windows es in the font name as DroidSansMono NF
        # so we need to override this
        base.alacritty.font.family = "DroidSansMono Nerd Font";
      };
    in
    {
      debug = {
        inherit overlays pkgs base;
      };
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
            modules = base.modules ++ [
              ./home.nix
            ];
            # optionally pass inarguments to module
            # we migrate this from in-place modules to allow flexibility
            # in this case, we can add "home" to input arglist of home.nix
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "hungtr";
                homeDirectory = "/home/hungtr";
              };
            };
          };
          "hungtr@bao" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = base.modules ++ [
              ./home.nix
              kde_module
              ./base/productive_desktop.nix
            ];
            # optionally pass inarguments to module
            # we migrate this from in-place modules to allow flexibility
            # in this case, we can add "home" to input arglist of home.nix
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
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
              {
                base.shells = {
                  shellInitExtra = ''
                '' + x11_wsl;
                };
              }
            ];
            # optionally pass inarguments to module
            # we migrate this from in-place modules to allow flexibility
            # in this case, we can add "home" to input arglist of home.nix
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "nixos";
                homeDirectory = "/home/nixos";
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
            modules = base.modules ++ [
              ./home.nix
              ./base/graphics.nix
              {
                base.graphics.enable = true;
                base.alacritty.font.family = "BitstreamVeraSansMono Nerd Font";
              }
            ];
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "hwtr";
                homeDirectory = "/home/hwtr";
                packages = [
                  pkgs.postman
                ];
              };
            };
          };
        };
    };
}
