{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (system: {
      default = pkgs.${system}.poetry2nix.mkPoetryApplication {projectDir = self;};
    });

    devShells = forAllSystems (system: {
      bootstrap = pkgs.${system}.mkShellNoCC {
        packages = [
          pkgs.${system}.poetry
        ];
      };
      default = pkgs.${system}.mkShellNoCC {
        packages = [
          (pkgs.${system}.poetry2nix.mkPoetryEnv {projectDir = self;})
          pkgs.${system}.poetry
        ];
      };
    });
  };
}
