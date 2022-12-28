{pkgs
,nixpkgs
,proj_root
,nixosDefaultVersion? "22.05"
,defaultSystem? "x86_64-linux"
,...}@inputs: let
  lib = pkgs.lib;
  
  # procedure = 
in {
  # short-hand to create a shell derivation
  # NOTE: this is pure. This means, env vars from devShells might not
  # be accessible unless MAYBE they are `export`ed
  shellAsDrv = {script, pname}: (pkgs.callPackage (
    # just a pattern that we must remember: args to this are children of pkgs.
    {writeShellScriptBin}: writeShellScriptBin pname script
  ) {});

  # Configures hosts as nixosConfiguration
  # [host_T] -> {host_T[int].hostName = type (nixpkgs.lib.nixosConfiguration);}
  mkHost = {hostName
  , nixosBareConfiguration
  , nixosVersion? nixosDefaultVersion
  , system? defaultSystem
  , preset? "base"}:  # base | minimal
  nixpkgs.lib.nixosSystem (nixosBareConfiguration // {
    inherit system;
    modules = [
      {
        system.stateVersion = nixosVersion;
        networking.hostName = hostName;
      }
      import "${proj_root}/modules/base.nix"
      import "${proj_root}/modules/tailscale.sys.nix"
    ] ++ nixosBareConfiguration.modules;
  });
}
