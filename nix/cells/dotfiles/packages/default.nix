{
  inputs,
  cell,
}: let
  inherit (inputs.nixpkgs) system;
  inherit (inputs.nix-boost.pkgs."${system}".mypkgs) poetry2nix;
  inherit (poetry2nix) mkPoetryApplication defaultPoetryOverrides;
in {
  kpcli-py = mkPoetryApplication {
    projectDir = inputs.kpcli-py;
    overrides = defaultPoetryOverrides.extend (self: super: {
      # TODO: add this to upstream poetry2nix
      tableformatter = super.tableformatter.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [self.setuptools self.cython_3];
        src = old.src;
      });

      kpcli = super.kpcli.overridePythonAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [self.setuptools];
      });
    });
  };
}
