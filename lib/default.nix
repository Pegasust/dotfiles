{pkgs
,nixpkgs
,proj_root
,agenix
,nixosDefaultVersion? "22.05"
,defaultSystem? "x86_64-linux"
,...}@inputs: let
  lib = pkgs.lib;
  serde = import ./serde.nix inputs // {inherit lib;};
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
  mkHost = {hostName
  , nixosBareConfiguration
  , finalInputs
  , users ? {}
  , nixosVersion? nixosDefaultVersion
  , system? defaultSystem
  , preset? "base"}:  # base | minimal 
  let 
    hardwareConfig = hostname: import "${proj_root.hosts.path}/${hostName}/hardware-configuration.nix";
  in nixpkgs.lib.nixosSystem (nixosBareConfiguration // {
    inherit system;
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
    ] ++ nixosBareConfiguration.modules;
    lib = finalInputs.lib;
  });
  inherit serde;
  inherit (serde) fromYaml fromYamlPath;
}
