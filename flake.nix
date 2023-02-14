{
  nixConfig = {
    accept-flake-config = true;
    experimental-features = "nix-command flakes";
    # for darwin's browser
    allowUnsupportedSystem = true;
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
      cross_platform = config_fn: let 
        # nixosConfigurations.${profile} -> nixosConfigurations.${system}.${profile}
        # pass in: path.to.exports.nixosConfigurations
        # get out: nixosConfigurations.${system} = {...}
        strat_sandwich = field_name: config_field: system: {
          "${field_name}"."${system}" = config_field;
        };
        # homeConfigurations.${profile} -> packages.${system}.homeConfigurations.${profile}
        # pass in: path.to.exports.homeConfigurations
        # get: packages.${system}.homeConfigurations
        strat_wrap_packages = field_name: config_field: system: {
          packages."${system}"."${field_name}" = config_field;
        };
        strat_noop = field_name: config_field: system: {"${field_name}" = config_field;};
        strategyMap = {
          nixosConfigurations = strat_sandwich;
          templates =           strat_noop;
          devShells =           strat_sandwich;
          devShell =            strat_sandwich;
          formatter =           strat_sandwich;
          homeConfigurations =  strat_wrap_packages;
          lib =                 strat_noop;
          proj_root =           strat_noop;
          unit_tests =          strat_noop;
          secrets =             strat_noop;
          debug =               strat_noop;
        };
        # takes in {homeConfigurations = ...; nixosConfigurations = ...}
        # -> {packages.$system.homeConfigurations}
        mapConfig = config: system: (builtins.foldl' 
          (acc: confName: (strategyMap."${confName}" confName config."${confName}" system))
          {} (builtins.attrNames config));
      in builtins.foldl' nixlib.lib.recursiveUpdate {} (
        builtins.map (system: (mapConfig (config_fn system) system)) flake-utils.lib.defaultSystems
      );
    in cross_platform (system:
    let
      # Context/global stuffs to be passed down
      # NOTE: this will only read files that are within git tree
      # all secrets should go into secrets.nix and secrets/*.age
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
      overlays = import ./overlays.nix (_inputs // {inherit system;});
      pkgs = import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      };
      # now, this lib is extremely powerful as it also engulfs nixpkgs.lib
      # lib = nixpkgs.lib // pkgs.lib;
      lib = (builtins.foldl' (lhs: rhs: (nixpkgs.lib.recursiveUpdate lhs rhs)) { } [
        nixpkgs.lib
        pkgs.lib
        (import ./lib {
          inherit proj_root pkgs overlays system;
          inherit (pkgs) lib;
        })
      ]);
      inputs_w_lib = (pkgs.lib.recursiveUpdate _inputs {
        inherit system proj_root pkgs lib;
      });

      modules = (import ./modules inputs_w_lib);
      hosts = (import ./hosts inputs_w_lib);
      users = (import ./users inputs_w_lib);

      # {nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
      # ,pkgs, lib (extended), proj_root}
      final_inputs = inputs_w_lib;

      # Tests: unit + integration
      unit_tests = (import ./lib/test.nix final_inputs) //
        {
          test_example = {
            expr = "names must start with 'test'";
            expected = "or won't show up";
          };
          not_show = {
            expr = "this will be ignored by lib.runTests";
            expected = "for sure";
          };
        };
      secrets = import ./secrets final_inputs;

    in
    {
      inherit (hosts) nixosConfigurations;
      inherit (users) homeConfigurations;
      inherit lib proj_root;
      devShells = import ./dev-shell.nix final_inputs;
      templates = import ./templates final_inputs;
      secrets = {
        pubKeys = {
          hosts = hosts.pubKeys;
          users = users.pubKeys;
        };
      };

      # unit_tests = lib.runTests unit_tests;
      debug = {
        inherit final_inputs hosts users modules lib inputs_w_lib unit_tests pkgs nixpkgs nixlib;
      };
      formatter."${system}" = pkgs.nixpkgs-fmt;
    });
}
