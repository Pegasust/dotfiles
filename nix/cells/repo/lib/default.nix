{ inputs, cell }:
let
  namespace = "repo";


  yamlToJsonDrv = pkgs: yamlContent: outputPath: (pkgs.runCommand
    outputPath
    { inherit yamlContent; nativeBuildInputs = [ pkgs.yq ]; }
    # run yq which outputs '.' (no filter) on file at yamlPath
    # note that $out is passed onto the bash/sh script for execution
    ''
      echo "$yamlContent" | yq >$out
    '')
    { });
in
{
  fromYAML = yamlContent: bulitins.fromJSON (builtins.readFile (yamlToJsonDrv inputs.nixpkgs yamlContent "fromYaml.json"));

  # NOTE: Deprecate
  # ctor
  opt-some = a: [ a ];
  opt-none = [ ];
  opt-none_thunk = _: [ ];

  # from-to null
  opt-fromNullable = nullable: if nullable == null then [ ] else [ nullable ];
  opt-toNullable = opt-fork (a:a) (_: null);

  opt-map = builtins.map;
  opt-filter = builtins.filter;
  opt-fork = on_some: on_none: opt: if opt == [ ] then (on_none null) else (on_some (builtins.elemAt opt 0));

  opt-unwrap = opt-fork (a:a) (_: throw "opt-unwrap: expected some, got none");
  opt-unwrapOrElse = opt-fork (a:a);
  opt-unwrapOr = fallback_val: opt-fork (a:a) (_: fallback_val);

  opt-orElse = opt: fallback_opt: opt-fork (opt-some) (opt-none_thunk) (opt ++ fallback_opt);
  opt-leftmostSome = opts: builtins.foldl' (opt-orElse) [ ] opts;
}
