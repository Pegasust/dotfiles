{inputs, cell}: let 
  inherit (inputs) std nixpkgs;

in {
  default = std.lib.dev.mkShell {
    name = "default";
    imports = [inputs.std.std.devshellProfiles.default];
  };
}
