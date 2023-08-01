{
  inputs,
  cell,
}: let
  inherit (inputs.nixpkgs) system;
  inherit (cell.packages) pixi-deps pixi-edit; 
in {
  pixi = inputs.nixpkgs.mkShell {
    buildInputs = [
      pixi-deps
      # pixi-edit
      inputs.std.packages.${system}.default
    ];
  };
}
