flake_input@{ kpcli-py
, nixgl
, rust-overlay
, neovim-nightly-overlay
, system
, ... 
}: let
  kpcli-py = (final: prev: {
    # use python3.9, which works because of cython somehow?
    kpcli-py = final.poetry2nix.mkPoetryApplication {
      projectDir = flake_input.kpcli-py;
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
  });

  rust = (final: prev: 
    let
      nightlyRustWithExts = exts: final.rust-bin.selectLatestNightlyWith (
        toolchain: (toolchain.minimal.override {
          extensions = exts;
        })
      );
      # https://rust-lang.github.io/rustup/concepts/profiles.html
      rust-default-components = [ "rust-docs" "rustfmt" "clippy" ];
      rust-dev-components = rust-default-components ++ [ "rust-src" "rust-analyzer" "miri" ];
    in {
      rust4devs = nightlyRustWithExts rust-dev-components;
      rust4cargo = nightlyRustWithExts [ ];
      rust4normi = nightlyRustWithExts rust-default-components;
  });
in [
  nixgl.overlays.default
  rust-overlay.overlays.default
  neovim-nightly-overlay.overlay
  rust
  kpcli-py
]

