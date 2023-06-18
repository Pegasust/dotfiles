{ inputs, cell }:
let
  namespace = "repo"; # ignore: unused

  yamlToJsonDrv = pkgs: yamlContent: outputPath: (pkgs.runCommand
    outputPath
    { inherit yamlContent; nativeBuildInputs = [ pkgs.yq ]; }
    # run yq which outputs '.' (no filter) on file at yamlPath
    # note that $out is passed onto the bash/sh script for execution
    ''
      echo "$yamlContent" | yq >$out
    '');
in
{
  fromYAML = yamlContent: builtins.fromJSON (builtins.readFile (yamlToJsonDrv inputs.nixpkgs yamlContent "fromYaml.json"));
}
