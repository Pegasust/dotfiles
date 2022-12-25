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
    nixgl.url = "github:guibou/nixGL";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
    ,...
  }@_inputs: let 
    # Context/global stuffs to be passed down
    # TODO: adapt to different platforms think about different systems later
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    # inject nixpkgs.lib onto c_ (calculus)
    _lib = pkgs.lib;
    inputs = (lib.recursiveUpdate {inherit system, })
    inputs_w_pkgs = (_lib.recursiveUpdate {inherit pkgs;} inputs);
    lib = _lib.recursiveUpdate (import ./lib inputs_w_pkgs) _lib;

    # update inputs with our library and past onto our end configurations
    inputs_w_lib = (lib.recursiveUpdate lib inputs_w_pkgs);
    modules = (import ./modules inputs_w_lib);
    hosts = (import ./hosts inputs_w_lib); 
    users = (import ./users inputs_w_lib);
    
    final_inputs = inputs_w_lib;
  in {
    # inherit (hosts) nixosConfigurations;
    # inherit (users) homeConfigurations;
    devShell = import ./shell final_inputs;
  };
}
