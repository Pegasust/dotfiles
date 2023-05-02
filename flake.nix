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
      modules = ./nix/modules;

      cellBlocks =
        let
          inherit (std.blockTypes) devShells;
          inherit (hive.blockTypes) nixosConfigurations homeConfigurations;
        in
        [
          (devShells "devshells")
          (nixosConfigurations "host_profile")
          (homeConfigurations "home_profile")

        ];
    }
    {
      devShells = std.harvest [ [ "dotfiles" "devshells" ] ];
      nixosConfigurations = std.harvest [ [ "dotfiles" "nixos" ] ];
      homeConfigurations = std.harvest [ [ "dotfiles" "home" ] ];
    };
}
