{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: {
    # Windows with NixOS WSL
    nixosConfigurations.Felia = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./wsl-configuration.nix
      ];
      specialArgs = {
        hostname = "Felia";
        enableSSH = false;
      };
    };
    # Generic machine
    nixosConfigurations.lizzi = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = {
        hostname = "lizzi";
      };
    };
    nixosConfigurations.nyx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = {
        hostname = "nyx";
      };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = {
        hostname = "nixos";
      };
    };
  };
}
