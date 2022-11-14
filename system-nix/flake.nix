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
        networking = {
          interfaces.eth1.ipv4.addresses = [{
            address = "71.0.0.1";
            prefixLength = 24;
          }];
          firewall.enable = false;
          useDHCP = false;
          interfaces.eth0.useDHCP = true;
        };
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        services.openssh = {
          permitRootLogin = "no";
          enable = enableSSH;
        };
      };
    };
    nixosConfigurations.nyx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = {
        hostname = "nyx";
        networking = {
          interfaces.eth1.ipv4.addresses = [{
            address = "71.0.0.2";
            prefixLength = 24;
          }];
          firewall.enable = false;
          useDHCP = false;
          interfaces.eth0.useDHCP = true;
        };
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        services.openssh = {
          permitRootLogin = "no";
          enable = enableSSH;
        };
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
