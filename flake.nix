{
  nixConfig = {
    accept-flake-config = true;
    experimental-features = "nix-command flakes";
    max-jobs = 12;
  };
  description = "My personal configuration in Nix (and some native configurations)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:nixos/nixpkgs";
    # deploy-rs.url = "github:serokell/deploy-rs";
    std = {
      url = "github:divnix/std";
      inputs.devshell.url = "github:numtide/devshell";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      # need to pin this until darwin build is successful again.
      url = "github:nix-community/neovim-nightly-overlay?rev=88a6c749a7d126c49f3374f9f28ca452ea9419b8";
      # url = "github:nix-community/neovim-nightly-overlay";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-boost = {
      url = "git+https://git.pegasust.com/pegasust/nix-boost?ref=bleed";
    };
    kpcli-py = {
      url = "github:rebkwok/kpcli";
      flake = false;
    };
    nix-index-database = {
      url = "github:mic92/nix-index-database";
      # Should show the latest nixpkgs whenever possible
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
    sg-nvim = {
      url = "git+https://github.com/pegasust/sg.nvim?ref=sg-cody-discover";
    };
  };

  outputs = {
    self,
    std,
    ...
  } @ inputs:
    std.growOn
    {
      # boilerplate
      inherit inputs;
      # All cell blocks are under ./nix/<cell>/<cellblock> as `<cellblock>.nix`
      # or `<cellblock/default.nix`
      cellsFrom = ./nix;
      # modules = ./nix/modules;

      cellBlocks = let
        inherit (std.blockTypes) devshells functions anything installables runnables;
      in [
        (installables "shells")
        (devshells "devshells")
        (devshells "userShells")
        (functions "home-profiles")
        (functions "home-modules")
        (anything "home-configs")
        (installables "packages")
        (anything "lib")
        (runnables "formatter")
      ];
    }
    {
      devShells = std.harvest self [["dotfiles" "devshells"] ["dev" "shells"]];
      homeModules = std.pick self [["repo" "home-modules"]];
      packages = std.harvest self [
        ["repo" "packages"]
        ["dev" "packages"]
      ];
      legacyPackages = std.harvest self [["repo" "home-configs"]];
      lib = std.pick self [["repo" "lib"]];

      # TODO: Debug only
      homeProfiles = std.pick self [["repo" "home-profiles"]];
      formatter = std.harvest self [["repo" "formatter"]];
    };
}
