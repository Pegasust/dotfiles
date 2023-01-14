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
            file = ./secrets/s3fs.age;
            # mode = "600";  # owner + group only
            # owner = "hungtr";
            # group = "users";
          };
          age.secrets."s3fs.digital-garden" = {
            file = ./secrets/s3fs.digital-garden.age;
          };
          age.secrets._nhitrl_cred = {
            file = ./secrets/_nhitrl.age;
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
      nixosConfigurations.bao = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.hostname = "bao";
        modules = base_modules ++ [
          ./configuration.nix
          ./../../modules/storage.perso.sys.nix
          # GPU, sound, networking stuffs
          ({ config, pkgs, lib, ... }:
            let
              gpu_pkgs = [ pkgs.clinfo pkgs.lshw pkgs.glxinfo pkgs.pciutils pkgs.vulkan-tools ];
              gpu_conf = {
                # openCL
                hardware.opengl = {
                  enable = true;
                  extraPackages =
                    let
                      inherit (pkgs) rocm-opencl-icd rocm-opencl-runtime;
                    in
                    [ rocm-opencl-icd rocm-opencl-runtime ];
                  # Vulkan
                  driSupport = true;
                  driSupport32Bit = true;
                  package = pkgs.mesa.drivers;
                  package32 = pkgs.pkgsi686Linux.mesa.drivers;
                };
              };
              amd_rx470 = {
                # early amd gpu usage
                boot.initrd.kernelModules = [ "amdgpu" ];
                services.xserver.enable = true;
                services.xserver.videoDrivers = [ "amdgpu" ];
              };
              nv_rtx3060 = {
                nixpkgs.config.allowUnfree = true;
                services.xserver.enable = true;
                services.xserver.videoDrivers = [ "nvidia" ];
                hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
              };
              systemPackages = [ ] ++ gpu_pkgs;
            in
            lib.recursiveUpdate gpu_conf (lib.recursiveUpdate nv_rtx3060 {
              # Use UEFI
              boot.loader.systemd-boot.enable = true;

              networking.hostName = "bao"; # Define your hostname.
              # Pick only one of the below networking options.
              # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
              networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

              # Enable the X11 windowing system.
              services.xserver.enable = true;
              # KDE & Plasma 5
              services.xserver.displayManager.sddm.enable = true;
              services.xserver.desktopManager.plasma5 = {
                enable = true;
                excludePackages = let plasma5 = pkgs.libsForQt5; in [
                  plasma5.elisa # audio viewer
                  plasma5.konsole # I use alacritty instaed
                  plasma5.plasma-browser-integration
                  plasma5.print-manager # will enable if I need
                  plasma5.khelpcenter # why not just write manpages instead :(
                  # plasma5.ksshaskpass   # pls just put prompts on my dear terminal
                ];
              };

              # disables KDE's setting of askpassword
              programs.ssh.askPassword = "";
              programs.ssh.enableAskPassword = false;

              time.timeZone = "America/Phoenix";
              # Configure keymap in X11
              services.xserver.layout = "us";
              # services.xserver.xkbOptions = {
              #   "eurosign:e";
              #   "caps:escape" # map caps to escape.
              # };

              # Enable CUPS to print documents.
              # services.printing.enable = true;

              # Enable sound. (pulse audio)
              sound.enable = true;
              programs.dconf.enable = true;
              hardware.pulseaudio.enable = true;
              hardware.pulseaudio.support32Bit = true;
              nixpkgs.config.pulseaudio = true;
              hardware.pulseaudio.extraConfig = "load-module module-combine-sink";

              # Sound: pipewire
              # sound.enable = false;
              # hardware.pulseaudio.enable = false;
              # services.pipewire = {
              #   enable = true;
              #   alsa.enable = true;
              #   alsa.support32Bit = true;
              #   pulse.enable = true;
              #   # Might want to use JACK in the future
              #   jack.enable = true;
              # };
              #
              # security.rtkit.enable = true;


              # Enable touchpad support (enabled default in most desktopManager).
              # services.xserver.libinput.enable = true;

              # Define a user account. Don't forget to set a password with ‘passwd’.
              # users.users.alice = {
              #   isNormalUser = true;
              #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
              #   packages = with pkgs; [
              #     firefox
              #     thunderbird
              #   ];
              # };
              # Just an initial user to get this started lol
              users.users.user = {
                initialPassword = "pw123";
                extraGroups = [ "wheel" "networkmanager" "audio" ];
                isNormalUser = true;
              };

              # List packages installed in system profile. To search, run:
              # $ nix search wget
              environment.systemPackages = with pkgs; [
                neovim
                wget
              ] ++ systemPackages;

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

              # Open ports in the firewall.
              # networking.firewall.allowedTCPPorts = [ ... ];
              # networking.firewall.allowedUDPPorts = [ ... ];
              # Or disable the firewall altogether.
              # networking.firewall.enable = false;

              # Copy the NixOS configuration file and link it from the resulting system
              # (/run/current-system/configuration.nix). This is useful in case you
              # accidentally delete configuration.nix.
              # system.copySystemConfiguration = true;

              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It‘s perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
              system.stateVersion = "22.11"; # Did you read the comment?
            }))
        ];
      };
    };
}
