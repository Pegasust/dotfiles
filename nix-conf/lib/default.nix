{
  pkgs,
  lib ? pkgs.lib,
  ...
} @ flake_import: let
  serde = import ./serde {inherit pkgs lib;};
  recursiveUpdate = lib.recursiveUpdate;
in
  recursiveUpdate (recursiveUpdate pkgs.lib lib) {
    fromYaml = serde.fromYaml;
    fromYamlPath = serde.fromYamlPath;
  }
