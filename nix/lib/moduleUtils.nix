{ flake-utils-plus
, lib
, ...
}: {
  # exportWithInputs [./a.nix ./b.nix] {my = "inputs";}
  # -> {a = import ./a.nix {my = "inputs";}, b = import ./b.nix {my = "inputs";}}
  exportWithInputs = modules: inputs: (
    lib.mapAttrs (name: value: (value inputs))
      (flake-utils-plus.lib.exportModules modules));
}
