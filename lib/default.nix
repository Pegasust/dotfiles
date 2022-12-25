{pkgs,...}@inputs: let
  lib = pkgs.lib;
in {
  # short-hand to create a shell derivation
  # NOTE: this is pure. This means, env vars from devShells might not
  # be accessible unless MAYBE they are `export`ed
  shellAsDrv = {script, pname}: (pkgs.callPackage (
    # just a pattern that we must remember: args to this are children of pkgs.
    {writeShellScriptBin}: writeShellScriptBin pname script
  ) {});
}
