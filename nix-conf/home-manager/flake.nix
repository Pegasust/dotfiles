{
  nixConfig = {
    accept-flake-config = true;
    experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  description = "simple home-manager config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "path:./../../out-of-tree/nixGL";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "path:../../out-of-tree/flake-compat";
      flake = false;
    };
    kpcli-py = {
      url = "github:rebkwok/kpcli";
      flake = false;
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
      inputs.nixpkgs.url = "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    flake_inputs@{ nixpkgs
    , home-manager
    , nixgl
    , rust-overlay
    , flake-utils
    , kpcli-py
    , neovim-nightly-overlay
    , ...
    }:
    let
      # config_fn:: system -> config
      cross_platform = config_fn: ({
        packages = builtins.foldl'
          (prev: system: prev // {
            "${system}" = config_fn system;
          })
          { }
          flake-utils.lib.defaultSystems;
      });
    in
    cross_platform (system:
    let
      overlays = import ./../../overlays.nix (flake_inputs // {inherit system;});
      # pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
      pkgs = import nixpkgs {
        inherit system overlays;
        config = { allowUnfree = true; };
      };
      # lib = (import ../lib { inherit pkgs; lib = pkgs.lib; });
      base = import ./base flake_inputs;
      inherit (base) mkModuleArgs;

      nerd_font_module = { config, pkgs, ... }: {
        fonts.fontconfig.enable = true;
        home.packages = [
          (pkgs.nerdfonts.override { fonts = [ "DroidSansMono" ]; })
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
        let
          x11_wsl = ''
            # x11 output for WSL
            export DISPLAY=$(ip route list default | awk '{print $3}'):0
            export LIBGL_ALWAYS_INDIRECT=1
          '';
        in
        {
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
              nerd_font_module
              ./base/productive_desktop.nix
              {
                # since home.nix forces us to use keepass, and base.keepass.path
                # defaults to a bad value (on purpose), we should configure a
                # it to be the proper path
                base.keepass.path = "/perso/garden/keepass.kdbx";
                base.graphics.useNixGL.defaultPackage = "nixGLNvidia";
                base.graphics.useNixGL.enable = true;
              }
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
          # Personal darwin, effectively serves as the Darwin edge channel
          "hungtran" = home-manager.lib.homeManagerConfiguration { 
            inherit pkgs;
            modules = base.modules ++ [
              ./home.nix
              {
                base.graphics.enable = false;
                # don't want to deal with GL stuffs on mac yet :/
                base.graphics.useNixGL.defaultPackage = null;
                # NOTE: this actually does not exist
                base.keepass.path = "/Users/hungtran/keepass.kdbx";
                base.alacritty.font.size = 11.0;
              }
              nerd_font_module
              ./base/productive_desktop.nix
              {
                base.private_chromium.enable = false;
              }
            ];
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "hungtran";
                homeDirectory = "/Users/hungtran";
              };
            };
          };
          # Work darwin
          "htran" = home-manager.lib.homeManagerConfiguration { 
            inherit pkgs;
            modules = base.modules ++ [
              ./home.nix
              ./base/productive_desktop.nix
              {
                base.private_chromium.enable = false;
              }
              {
                base.graphics.enable = false;
                # don't want to deal with GL stuffs on mac yet :/
                base.graphics.useNixGL.defaultPackage = null;
                # NOTE: this actually does not exist
                base.keepass.path = "/Users/htran/keepass.kdbx";
                base.alacritty.font.size = 11.0;
                base.git.name = "Hung";
                base.git.email = "htran@egihosting.com";
              }
              nerd_font_module
            ];
            extraSpecialArgs = mkModuleArgs {
              inherit pkgs;
              myHome = {
                username = "htran";
                homeDirectory = "/Users/htran";
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
                base.keepass.path = "/media/homelab/f/PersistentHotStorage/keepass.kdbx";
              }
              ./base/productive_desktop.nix
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
    });
}
