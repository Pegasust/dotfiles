{
  nixConfig = {
    accept-flake-config = true;
    experimental-features = "nix-command flakes";
    max-jobs = 12;
  };
  description = "My personal configuration in Nix (and some native configurations)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    std.url = "github:divnix/std";
    hive.url = "github:divnix/hive";
  };

  outputs = { std, hive, ... }@inputs: std.growOn
    {
      # boilerplate
      inherit inputs;
      # All cell blocks are under ./nix/cells/<cell>/<cellblock> as `<cellblock>.nix`
      # or `<cellblock/default.nix`
      cellsFrom = ./nix/cells;
      # modules = ./nix/modules;

      cellBlocks =
        let
          inherit (std.blockTypes) devshells functions;
        in
        [
          (devshells "devshells")
          (devshells "userShells")
          # (functions "host_profile")
          # (functions "home_profile")

        ];
    }
    {
      devShells = std.harvest [ [ "dotfiles" "devshells" ] ];
      # nixosConfigurations = std.pick [ [ "dotfiles" "nixos" ] ];
      # homeConfigurations = std.pick [ [ "dotfiles" "home" ] ];
      homeModules = std.pick [["repo" "home-modules"]];
    };
}
