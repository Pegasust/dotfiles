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
        # includeHardware = false;
        hostname = "Felia";
        services.openssh = {
          permitRootLogin = "no";
          enable = true;
        };
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
          enable = true;
        };
        services.gitea = {
          enable = true;
          stateDir = "/gitea";
          rootUrl = "https://git.pegasust.com";
          settings = {
            repository = {
              "ENABLE_PUSH_CREATE_USER" = true;
              "ENABLE_PUSH_CREATE_ORG" = true;
            };
          };
        };
        services.nginx = {
          enable = true;
          clientMaxBodySize = "100m";
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
          virtualHosts."git.pegasust.com" = {
            # Gitea hostname
            sslCertificate = "/var/lib/acme/git.pegasust.com/fullchain.pem";
            sslCertificateKey = "/var/lib/acme/git.pegasust.com/key.pem";
            forceSSL = true; # Runs on port 80 and 443
            locations."/".proxyPass = "http://localhost:3000/"; # Proxy to Gitea
          };
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
          enable = true;
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
