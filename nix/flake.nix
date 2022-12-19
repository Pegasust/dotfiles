{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    # for OpenGL support on Nix
    nixgl.url = "github:guibou/nixGL";
    # S-tier Rust overlay for faster nightly updates 
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Allows default.nix to call onto flake.nix. Useful for nix eval and automations
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    naersk.url = "github:nix-community/naersk";
  };
  outputs =
    { nixpkgs
    , home-manager
    , flake-utils-plus
    , nixgl
    , rust-overlay
      # , flake-compat # This is only a placeholder for version control by flake.lock
    , naersk
    , ...
    }:

    let
      # fundamental functions that should only take 2 keystrokes instead of builtins (8)
      c_ = import ./calculus;
      overlays = [ rust-overlay.overlays.default nixgl.overlay ];
    in 
    { };

}
