{
  nixConfig = {
    accept-flake-config = true;
    experimental-features = "nix-command flakes";
    max-jobs = 4;
  };
  description = "My personal configuration in Nix (and some native configurations)";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # continously merged & rebased lightweight .lib. Basically a huge extension to c_.
    nixlib.url = "github:nix-community/nixpkgs.lib";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "path:out-of-tree/nixGL";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "path:out-of-tree/flake-compat";
      flake = false;
    };
    kpcli-py = {
      url = "github:rebkwok/kpcli";
      flake = false;
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.url = "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nickel.url = "github:tweag/nickel";
  };

  outputs =
    { nixpkgs
    , agenix
    , home-manager
    , flake-utils
    , nixgl
    , rust-overlay
    , flake-compat
    , neovim-nightly-overlay
    , nix-index-database
    , nixlib
    , nickel
    , ...
    }@_inputs:
    let
      # config_fn:: system -> config
      # this function should take simple exports of homeConfigurations.${profile}, 
      # nixosConfigurations.${profile}, devShells.${profile}, packages.${profile}
      # and correctly produce 
      supported_systems = flake-utils.lib.defaultSystems;
      forEachSystem = nixpkgs.lib.genAttrs supported_systems;
    in
    let
      proj_root =
        let
          path = builtins.toString ./.;
        in
        {
          inherit path;
          configs.path = "${path}/native_configs";
          scripts.path = "${path}/scripts";
          secrets.path = "${path}/secrets";
          testdata.path = "${path}/tests";
          modules.path = "${path}/modules";
          hosts.path = "${path}/hosts";
          users.path = "${path}/users";
        };
      overlays = forEachSystem (system: import ./overlays.nix (_inputs // { inherit system; }));
      pkgs = forEachSystem (system: (import nixpkgs {
        inherit system;
        overlays = overlays.${system};
        config = {
          allowUnfree = true;
        };
      }));
      lib = (builtins.foldl' (lhs: rhs: (nixpkgs.lib.recursiveUpdate lhs rhs)) { } [
        nixpkgs.lib
        nixlib.lib
      ]);
      inputs_w_lib = forEachSystem (
        system: lib.recursiveUpdate _inputs {
          inherit system lib;
          pkgs = pkgs.${system};
        }
      );

      modules = (import ./modules inputs_w_lib);
      hosts = (import ./hosts inputs_w_lib);
      users = (import ./users inputs_w_lib);

      # {nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
      # ,pkgs, lib (extended), proj_root}
      final_inputs = inputs_w_lib;
    in
    {
      inherit (hosts) nixosConfigurations;
      inherit (users) homeConfigurations;
      inherit lib proj_root;
      devShells = forEachSystem (system:
        {default = (import ./dev-shell.nix final_inputs.${system});}
      );
      templates = forEachSystem (system: import ./templates final_inputs.${system});
      secrets = {
        pubKeys = {
          hosts = hosts.pubKeys;
          users = users.pubKeys;
        };
      };

      debug = {
        inherit final_inputs hosts users modules lib inputs_w_lib pkgs nixpkgs nixlib;
      };
      # formatter."${system}" = pkgs.nixpkgs-fmt;
    };
}
