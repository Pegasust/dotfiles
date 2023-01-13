{ nixpkgs
, agenix
, home-manager
, flake-utils
, nixgl
, rust-overlay
, flake-compat
, pkgs
, lib
, proj_root
, nixosDefaultVersion ? "22.05"
, defaultSystem ? "x86_64-linux"
, ...
}@finalInputs:
let
  config = {
    bao.metadata = {
      # req
      hostName = "bao";
      # opts
      ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBuAaAE7TiQmMH300VRj/pYCri1qPmHjd+y9aX2J0Fs";
      nixosVersion = "22.11";
      system = "x86_64-linux";
      preset = "base";
    };
    # TODO: add override so that we can add wsl config on top
    bao.nixosConfig = {
      modules = [
        (import ../modules/nvgpu.sys.nix)
        (import ../modules/kde.sys.nix)
        (import ../modules/pulseaudio.sys.nix)
        (import ../modules/storage.perso.sys.nix)
      ];
    };
  };
  propagate = hostConfig@{ metadata, nixosConfig }:
    let
      # req
      inherit (metadata) hostName;
      # opts
      ssh_pubkey = lib.attrByPath [ "ssh_pubkey" ] null metadata; # metadata.ssh_pubkey??undefined
      users = lib.attrByPath [ "users" ] { } metadata;
      nixosVersion = lib.attrByPath [ "nixosVersion" ] nixosDefaultVersion metadata;
      system = lib.attrByPath [ "system" ] defaultSystem metadata;
      preset = lib.attrByPath [ "preset" ] "base" metadata;
      # infer
      hardwareConfig = import "${proj_root.hosts.path}/${hostName}/hardware-configuration.nix";
      # alias to prevent infinite recursion
      _nixosConfig = nixosConfig;
    in
    {
      inherit hostName ssh_pubkey users nixosVersion system preset hardwareConfig;
      nixosConfig = _nixosConfig // {
        inherit system;
        modules = [
          {
            config._module.args = {
              inherit proj_root;
              my-lib = finalInputs.lib;
            };
          }
          hardwareConfig
          {
            system.stateVersion = nixosVersion;
            networking.hostName = hostName;
            users.users = users;
          }
          {
            imports = [ agenix.nixosModule ];
            environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];
          }
          (import "${proj_root.modules.path}/secrets.nix")
          (import "${proj_root.modules.path}/${preset}.sys.nix")
        ] ++ _nixosConfig.modules;
      };
    };
  # we are blessed by the fact that we engulfed nixpkgs.lib.* at top level
  mkHostFromPropagated = propagatedHostConfig@{ nixosConfig, ... }: nixpkgs.lib.nixosSystem nixosConfig;
  <<<<<<< HEAD
    mkHost = hostConfig: (lib.pipe [ propagate mkHostFromPropagated ] hostConfig);
  trimNull = lib.filterAttrsRecursive (name: value: value != null);
  flattenPubkey = lib.mapAttrs (hostName: meta_config: meta_config.metadata.ssh_pubkey);
  =======
  mkHost = hostConfig: (lib.pipe hostConfig [ propagate mkHostFromPropagated ]);
  >>>>>>> 4619ea4 (rekey)
  in {
  nixosConfigurations = lib.mapAttrs (name: hostConfig: mkHost hostConfig) config;
  # {bao = "ssh-ed25519 ..."; another_host = "ssh-rsa ...";}
  pubKeys = lib.getPubkey config;
  }
