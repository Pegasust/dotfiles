flake_input@{ kpcli-py
, nixgl
, rust-overlay
, neovim-nightly-overlay
, system
, nix-boost
, nixpkgs-latest
, ...
}:
let
  kpcli-py = (final: prev: {
    # use python3.9, which works because of cython somehow?
    kpcli-py = final.poetry2nix.mkPoetryApplication {
      projectDir = flake_input.kpcli-py;
      overrides = final.poetry2nix.defaultPoetryOverrides.extend (self: super: {
        # tableformatter requires setuptools
        tableformatter = super.tableformatter.overridePythonAttrs (
          old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ self.setuptools self.cython_3 ];
            src = old.src;
          }
        );
        kpcli = super.kpcli.overridePythonAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ self.setuptools ];
        });

        # ubersmith = super.ubersmith.overridePythonAttrs (old: {
        #   buildInputs = builtins.filter (x: ! builtins.elem x [ ]) ((old.buildInputs or [ ]) ++ [
        #     py-final.setuptools
        #     py-final.pip
        #   ]);
        #
        #   src = final.fetchFromGitHub {
        #     owner = "jasonkeene";
        #     repo = "python-ubersmith";
        #     rev = "0c594e2eb41066d1fe7860e3a6f04b14c14f6e6a";
        #     sha256 = "sha256-Dystt7CBtjpLkgzCsAif8WkkYYeLyh7VMehAtwoDGuM=";
        #   };
        # });

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
    in
    {
      rust4devs = nightlyRustWithExts rust-dev-components;
      rust4cargo = nightlyRustWithExts [ ];
      rust4normi = nightlyRustWithExts rust-default-components;
    });


  vimPlugins = (final: prev: {
    inherit (nixpkgs-latest.legacyPackages.${system}) vimPlugins;
  });
in
[
  nix-boost.overlays.default
  nixgl.overlays.default
  rust-overlay.overlays.default
  neovim-nightly-overlay.overlay
  rust
  kpcli-py
  vimPlugins
]
