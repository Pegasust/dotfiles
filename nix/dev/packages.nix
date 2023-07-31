{
  inputs,
  cell,
}: let
  inherit (inputs.nixpkgs) system;
  poetry2nix = inputs.nix-boost.inputs.poetry2nix.legacyPackages.${system};

  pixi-src = "${inputs.self}/dev/pixi";
in {
  pixi-deps = poetry2nix.mkPoetryEnv {
    projectDir = pixi-src;
  };
  pixi-edit = poetry2nix.mkPoetryEditablePackage {
    projectDir = pixi-src;
    editablePackageSources = {
      pixi = pixi-src;
    };
  };
}
