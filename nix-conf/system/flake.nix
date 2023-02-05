{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, ... }:
    let
      lib = nixpkgs.lib;
      proj_root = ./../..;
      # TODO: Change respectively to the system or make a nix shell to alias `nix run github:ryantm/agenix -- `
      base_modules = [
        agenix.nixosModule
        {
          age.secrets.s3fs = {
            file = ../../secrets/s3fs.age;
            # mode = "600";  # owner + group only
            # owner = "hungtr";
            # group = "users";
          };
          age.secrets."s3fs.digital-garden" = {
            file = ../../secrets/s3fs.digital-garden.age;
          };
          age.secrets._nhitrl_cred = {
            file = ../../secrets/_nhitrl.age;
          };
          environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];
        }
      ];
    in
    {
      # Windows with NixOS WSL
      nixosConfigurations.Felia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = base_modules ++ [
          ./wsl-configuration.nix
          {
            system.stateVersion = "22.05";
          }
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
      nixosConfigurations.lizzi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = base_modules ++ [
          ./configuration.nix
          {
            system.stateVersion = "22.05";
            mod.tailscale.enable = true;
          }
        ];
        specialArgs = {
          hostname = "lizzi";
          _networking = {
            interfaces.eth1.ipv4.addresses = [{
              address = "71.0.0.1";
              prefixLength = 24;
            }];
            firewall = {
              enable = true;
              allowedTCPPorts = [ 80 443 22 ];
            };
            useDHCP = false;
            # required so that we get IP address from linode
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
          # Highly suspect that thanks to nginx, ipv6 is disabled?
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
      # Generic machine
      nixosConfigurations.pixi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = base_modules ++ [
          ./configuration.nix
          {
            system.stateVersion = "22.05";
          }
        ];
        specialArgs = {
          hostname = "pixi";
          _networking = {
            # interfaces.eth1.ipv4.addresses = [{
            #   address = "71.0.0.1";
            #   prefixLength = 24;
            # }];
            firewall = {
              enable = false;
              allowedTCPPorts = [ 80 443 22 ];
            };
            useDHCP = false;
            # interfaces.eth0.useDHCP = true;
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
      nixosConfigurations.nyx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = base_modules ++ [
          ./configuration.nix
          {
            system.stateVersion = "22.05";
          }
        ];
        specialArgs = {
          hostname = "nyx";
          _networking = {
            enableIPv6 = false;
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
        modules = base_modules ++ [
          ./configuration.nix
          {
            system.stateVersion = "22.05";
          }
        ];
        specialArgs = {
          hostname = "nixos";
        };
      };
      nixosConfigurations.htran-dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = base_modules ++ [
          ./configuration.nix
          {
            system.stateVersion = "22.11";
            mod.tailscale.enable = false;
            networking.defaultGateway = {
              address = "10.100.200.1";
              # interface = "ens32";
            };
            networking.interfaces.ens32.ipv4.addresses = [
              { address = "10.100.200.230"; prefixLength = 24; }
            ];
          }
        ];
        specialArgs = {
          hostname = "htran-dev";
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
      nixosConfigurations.bao = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.hostname = "bao";
        modules = base_modules ++ [
          ./configuration.nix
          ./../../modules/storage.perso.sys.nix
          ./../../modules/kde.sys.nix
          # GPU, sound, networking stuffs
          ./../../modules/pulseaudio.sys.nix
          ./../../modules/opengl.sys.nix
          ./../../modules/nvgpu.sys.nix
          ({ config, pkgs, lib, ... }:
            {
              mod.tailscale.enable = true;
              # Use UEFI
              boot.loader.systemd-boot.enable = true;

              networking.hostName = "bao"; # Define your hostname.
              # Pick only one of the below networking options.
              # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
              networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

              time.timeZone = "America/Phoenix";
              # Configure keymap in X11
              services.xserver.layout = "us";
              # services.xserver.xkbOptions = {
              #   "eurosign:e";
              #   "caps:escape" # map caps to escape.
              # };

              # Enable CUPS to print documents.
              # services.printing.enable = true;

              # Enable touchpad support (enabled default in most desktopManager).
              # services.xserver.libinput.enable = true;
              # Just an initial user to get this started lol
              users.users.user = {
                initialPassword = "pw123";
                extraGroups = [ "wheel" "networkmanager" "audio" ];
                isNormalUser = true;
              };

              # Some programs need SUID wrappers, can be configured further or are
              # started in user sessions.
              # programs.mtr.enable = true;
              # programs.gnupg.agent = {
              #   enable = true;
              #   enableSSHSupport = true;
              # };

              # List services that you want to enable:

              # Enable the OpenSSH daemon.
              services.openssh.enable = true;

              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It‘s perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
              system.stateVersion = "22.11"; # Did you read the comment?
            })
        ];
      };
    };
}
