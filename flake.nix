{
  description = "My personal configuration in Nix (and some native configurations)";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
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
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    kpcli-py = {
      url = "github:rebkwok/kpcli";
      flake = false;
    };
  };

  outputs = {
    nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
    ,...
  }@_inputs: let 
    # Context/global stuffs to be passed down
    # NOTE: this will only read files that are within git tree
    # all secrets should go into secrets.nix and secrets/*.age
    proj_root = let 
      path = builtins.toString ./.;
    in {
      inherit path;
      configs.path = "${path}/native_configs";
      scripts.path = "${path}/scripts";
      secrets.path = "${path}/secrets";
      testdata.path = "${path}/tests";
      modules.path = "${path}/modules";
      hosts.path = "${path}/hosts";
      users.path = "${path}/users";
    };
    # TODO: adapt to different platforms think about different systems later
    system = "x86_64-linux";
    overlays = [
      rust-overlay.overlays.default
      (self: pkgs@{lib,...}: {
        lib = pkgs.lib // (import ./lib (_inputs // {inherit pkgs proj_root;}));
      })
    ];
    pkgs = import nixpkgs {
      inherit system;
      overlays = import ./overlays.nix _inputs;
      config = {
        allowUnfree = true;
      };
    };
    # now, this lib is extremely powerful as it also engulfs nixpkgs.lib
    # TODO: I really don't want to extend from nixpkgs.lib because it doesn't extend lib within nixosModule
    lib = nixpkgs.lib.extend (self: nixpkgs_lib: (nixpkgs_lib // pkgs.lib));
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

  in {
    inherit (hosts) nixosConfigurations;
    inherit (users) homeConfigurations;
    inherit lib proj_root;
    devShell."${system}" = import ./dev-shell.nix final_inputs;
    templates = import ./templates final_inputs;
    secrets = {
      pubKeys = {
        hosts = hosts.pubKeys;
        users = users.pubKeys;
      };
    };

    unit_tests = lib.runTests unit_tests;
    debug = {
      inherit final_inputs hosts users modules lib unit_tests pkgs;
    };
  };
}
