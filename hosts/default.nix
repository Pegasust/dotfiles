{nixpkgs, agenix, home-manager, flake-utils, nixgl, rust-overlay, flake-compat
,pkgs, lib, proj_root,...}@inputs:{
  nixosConfigurations = {
    bao = lib.mkHost {
      hostName = "bao";
      nixosBareConfiguration = {
        modules = [
          
          import ../modules/kde.sys.nix
          import ../modules/pulseaudio.sys.nix
          import ../modules/storage.perso.sys.nix
        ];
      };
    };
  };
}
