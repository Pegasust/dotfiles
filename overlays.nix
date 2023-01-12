flake_input@{ kpcli-py, nixgl, rust-overlay, neovim-nightly-overlay, ... }: [

  nixgl.overlays.default

  rust-overlay.overlays.default

  neovim-nightly-overlay.overlay

  (final: prev:
    let
      nightlyRustWithExts = exts: final.rust-bin.selectLatestNightlyWith (
        toolchain: (toolchain.minimal.override {
          extensions = exts;
        })
      );
      # https://rust-lang.github.io/rustup/concepts/profiles.html
      rust-default-components = [ "rust-docs" "rustfmt" "clippy" ];
      rust-dev-components = rust-default-components ++ [ "rust-src" "rust-analyzer" "miri" ];
    in
    {
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

      rust4devs = nightlyRustWithExts rust-dev-components;
      rust4cargo = nightlyRustWithExts [ ];
      rust4normi = nightlyRustWithExts rust-default-components;
    })

]

