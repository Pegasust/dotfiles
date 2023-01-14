# Takes care of serializing and deserializing to some formats
# Blame: Pegasust<pegasucksgg@gmail.com>
# TODO: Add to* formats from pkgs.formats.*
{ pkgs
, lib
, ...
} @ inputs:
let
  yamlToJsonDrv = yamlContent: outputPath: pkgs.callPackage
    ({ runCommand }:
      # runCommand source: https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/trivial-builders.nix#L33
      runCommand outputPath { inherit yamlContent; nativeBuildInputs = [ pkgs.yq ]; }
        # run yq which outputs '.' (no filter) on file at yamlPath
        # note that $out is passed onto the bash/sh script for execution
        ''
          echo "$yamlContent" | yq >$out
        '')
    { };
in
{
  # Takes in a yaml string and produces a derivation with translated JSON at $outputPath
  # similar to builtins.fromJSON, turns a YAML string to nix attrset
  fromYaml = yamlContent: builtins.fromJSON (builtins.readFile (yamlToJsonDrv yamlContent "any_output.json"));
  fromYamlPath = yamlPath: builtins.fromJSON (
    builtins.readFile (
      yamlToJsonDrv
        (
          builtins.readFile yamlPath)
        "any-output.json"));
  # TODO: fromToml?
}
