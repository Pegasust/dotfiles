{ pkgs
, lib
, ... }@flake_import:
let serde = import ./serde { inherit pkgs lib; };
in
pkgs.lib // lib // {
  fromYaml = serde.fromYaml;
  fromYamlPath = serde.fromYamlPath;
}
