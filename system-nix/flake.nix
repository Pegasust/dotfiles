{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let lib = nixpkgs.lib; in
    {
      # Windows with NixOS WSL
      nixosConfigurations.Felia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./wsl-configuration.nix
        ];
        specialArgs = {
          # includeHardware = false;
          hostname = "Felia";
          _services.openssh = {
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
          _networking = {
            interfaces.eth1.ipv4.addresses = [{
              address = "71.0.0.1";
              prefixLength = 24;
            }];
            firewall = {
              enable = false;
              allowedTCPPorts = [ 80 443 ];
            };
            useDHCP = false;
            interfaces.eth0.useDHCP = true;
          };
          _boot.loader.grub.enable = true;
          _boot.loader.grub.version = 2;
          _services.openssh = {
            permitRootLogin = "no";
            enable = true;
          };
          _services.gitea = {
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
          _services.nginx = {
            enable = true;
            clientMaxBodySize = "100m"; # Allow big file transfers over git :^)
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
      nixosConfigurations.lester = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
        specialArgs = {
          hostname = "lester";
          _networking = {
            firewall.enable = true;
            useDHCP = false;
            interfaces.eth0.useDHCP = true;
          };
          _boot.loader.grub.enable = true;
          _boot.loader.grub.version = 2;
          _services.openssh = {
            permitRootLogin = "no";
            enable = true;
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
          _networking = {
            interfaces.eth1.ipv4.addresses = [{
              address = "71.0.0.2";
              prefixLength = 24;
            }];
            firewall.enable = true;
            useDHCP = false;
            interfaces.eth0.useDHCP = true;
          };
          _boot.loader.grub.enable = true;
          _boot.loader.grub.version = 2;
          _services.openssh = {
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
