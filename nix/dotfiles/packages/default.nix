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

  # sg-nvim = inputs.nixpkgs.vimUtils.buildVimPluginFrom2Nix {
  #   pname = "sg.nvim";
  #   version = "2023-06-20";
  #   src = inputs.nixpkgs.fetchFromGitHub {
  #     owner = "sourcegraph";
  #     repo = "sg.nvim";
  #     rev = "b87f87614357e0a7e6ff888918532ea11e87feb3";
  #     sha256 = "1xmj05i4bw2cx9d18mm85ynkn29dkngn5090r71wssvan6dm3fb4";
  #   };
  #   meta.homepage = "https://github.com/sourcegraph/sg.nvim/";
  # };
  sg-nvim = inputs.sg-nvim.packages.${system}.default;
}
