{nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
,pkgs, lib, proj_root, nixosDefaultVersion? "22.05", defaultSystem? "x86_64-linux",...}@finalInputs: let
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
  bao.nixosConfig = {
    modules = [
      import ../modules/kde.sys.nix
      import ../modules/pulseaudio.sys.nix
      import ../modules/storage.perso.sys.nix
    ];
  };
};
propagate = hostConfig@{metadata, nixosConfig}: let 
  # req
  inherit (metadata) hostName;
  # opts
  ssh_pubkey = lib.attrByPath ["ssh_pubkey"] null metadata; # metadata.ssh_pubkey??undefined
  users = lib.attrByPath ["users"] {} metadata;
  nixosVersion = lib.attrByPath ["nixosVersion"] nixosDefaultVersion metadata;
  system = lib.attrByPath ["system"] defaultSystem metadata;
  preset = lib.attrByPath ["preset"] "base" metadata;
  # infer
  hardwareConfig = import "${proj_root.hosts.path}/${hostName}/hardware-configuration.nix";
in {
  inherit hostName ssh_pubkey users nixosVersion system preset hardwareConfig;
  nixosConfig = nixosConfig // {
    inherit system;
    lib = finalInputs.lib;
    modules = [
      {
        system.stateVersion = nixosVersion;
        networking.hostName = hostName;
        users.users = users;
      }
      {
        _module.args = finalInputs;
      }
      import "${proj_root.modules.path}/secrets.nix"
      import "${proj_root.modules.path}/${preset}.sys.nix"
    ] ++ nixosConfig.modules;
  };
};
mkHostFromPropagated = propagatedHostConfig@{nixosConfig,...}: nixpkgs.lib.nixosSystem nixosConfig;
mkHost = hostConfig: (lib.pipe [propagate mkHostFromPropagated] hostConfig);
trimNull = lib.filterAttrsRecursive (name: value: value != null);
flattenPubkey = lib.mapAttrs (hostName: meta_config: meta_config.metadata.ssh_pubkey);
in {
  inherit config;
  # nixosConfigurations = lib.mapAttrs (name: hostConfig: mkHost hostConfig) config;
  nixosConfigurations = {};
  debug = {
    propagated = lib.mapAttrs (name: hostConfig: propagate hostConfig) config;
  };
  # {bao = "ssh-ed25519 ..."; another_host = "ssh-rsa ...";}
  hostKeys = trimNull (flattenPubkey config);
}
