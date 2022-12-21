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
      private_chromium = {config, pkgs, lib, ...}: let cfg = config.base.private_chromium;
      in {
        options.base.private_chromium = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            example = false;
            description = ''
            Enable extremely lightweight chromium with vimium plugin
            '';
          };
        };
        config = lib.mkIf cfg.enable {
          # home.packages = [pkgs.ungoogled-chromium];
          programs.chromium = {
            enable = true;
            package = pkgs.ungoogled-chromium;
            extensions = 
            let
              mkChromiumExtForVersion = browserVersion: {id, sha256, extVersion,...}:
              {
                inherit id;
                crxPath = builtins.fetchurl {
                  url = "https://clients2.google.com/service/update2/crx"+
                    "?response=redirect"+
                    "&acceptformat=crx2,crx3"+
                    "&prodversion=${browserVersion}"+
                    "&x=id%3D${id}%26installsource%3Dondemand%26uc";
                  name = "${id}.crx";
                  inherit sha256;
                };
                version = extVersion;
              };
              mkChromiumExt = mkChromiumExtForVersion (lib.versions.major pkgs.ungoogled-chromium.version);
            in
            [
              # vimium
              (mkChromiumExt {
                id = "dbepggeogbaibhgnhhndojpepiihcmeb"; 
                sha256 = "00qhbs41gx71q026xaflgwzzridfw1sx3i9yah45cyawv8q7ziic"; 
                extVersion = "1.67.4";
              })
            ];
          };
        };
      };
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
              private_chromium
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
              {
                base.alacritty.font.family = "BitstreamVeraSansMono Nerd Font";
                base.shells = {
                  shellAliases = {
                    nixGL = "nixGLIntel";
                  };
                };
              }
            ];
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "hwtr";
                homeDirectory = "/home/hwtr";
                packages = [
                  pkgs.nixgl.nixGLIntel
                  pkgs.postman
                ];
              };
            };
          };
        };
    };
}
