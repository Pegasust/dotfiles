flake_input@{ kpcli-py, nixgl, rust-overlay, ... }: [
  nixgl.overlays.default
  rust-overlay.overlays.default
  (final: prev: {
    # use python3.9, which works because of cython somehow?
    kpcli-py = final.poetry2nix.mkPoetryApplication {
      projectDir = kpcli-py;
      python = final.python39;
      overrides = final.poetry2nix.defaultPoetryOverrides.extend (self: super: {
        # tableformatter requires setuptools
        tableformatter = super.tableformatter.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools super.cython_3 ];
          }
        );
      });
    };
  })
]

