# Contains all of the utilities to help build this monorepo
# NOTE: lib is evaluated after overlays, but before import of mypkgs
# since mypkgs is dependent on ./lib
# In the future, if we need to develop utilities on top of mypkgs,
# use public_lib instead
{ pkgs
, lib ? pkgs.lib
, ...
}@flake_import:
let
  moduleUtils = import ./moduleUtils flake_import;
  inherit (moduleUtils.exportWithInputs [ ./serde ] flake_import) serde;

  recursiveUpdate = lib.recursiveUpdate;
in
recursiveUpdate (recursiveUpdate pkgs.lib lib) {
  fromYaml = serde.fromYaml;
  fromYamlPath = serde.fromYamlPath;
  inherit (moduleUtils) exportWithInputs;
}
