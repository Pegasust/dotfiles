{ flake-utils-plus
, lib
, ...
}: {
  # exportWithInputs [./a.nix ./b.nix] {my = "inputs";}
  # -> {a = import ./a.nix {my = "inputs";}, b = import ./b.nix {my = "inputs";}}
  exportWithInputs = modules: inputs: (
    lib.mapAttrs (name: value: (value inputs))
      (flake-utils-plus.lib.exportModules modules));
  mkModuleArgs =
    # This shows the config fields that these modules are expected to have
    # usage: [extra]specialArgs = mkModuleArgs {pkgs, lib,...} @ inputs
    # Note that mkModuleArgs also recursively merges `inputs`
    { pkgs, lib ? pkgs.lib, ... }@inputs:
    let
      recursiveUpdate = lib.recursiveUpdate;
      _lib = recursiveUpdate lib (import ../../lib { inherit pkgs lib; });
    in
    # TODO: Unpollute inputs
    recursiveUpdate inputs {
      proj_root = builtins.toString ./../..;
      myLib = _lib;
    };
}
