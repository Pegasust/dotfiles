{ pkgs, lib, config, ... }:
let
  # NOTE: Failure 1: buildInputs is pretty much ignored
  #   my_neovim = pkgs.neovim-unwrapped.overrideDerivation (old: {
  # # TODO: is there a more beautiful way to override propagatedBuildInputs?
  #     name = "hungtr-" + old.name;
  #     buildInputs = (old.buildInputs or []) ++ [
  #       pkgs.tree-sitter # highlighting
  #       rust_pkgs        # for potentially rust-analyzer
  #       pkgs.fzf
  #       pkgs.ripgrep
  #       pkgs.zk
  #       pkgs.fd
  #     ];
  # NOTE: Failure 2: propagatedBuildInputs probably only concerns dyn libs
  #   });
  # NOTE: Failure 3: must be unwrapped neovim because home-manager does the wrapping
  # my_neovim = pkgs.neovim;

  # NOTE: Add packages to nvim_pkgs instead, so that it's available at userspace
  # and is added to the path after wrapping.
  # check: nix repl `homeConfigurations.hungtr.config.programs.neovim.finalPackage.buildCommand`
  # see: :/--suffix.*PATH
  # there should be mentions of additional packages
  my_neovim = pkgs.neovim-unwrapped;
  rust_pkgs = (pkgs.rust-bin.selectLatestNightlyWith
    (
      toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" ];
      }
    ));
  nvim_pkgs = [
    # pkgs.gccStdenv
    pkgs.gcc
    pkgs.tree-sitter
    pkgs.fzf # file name fuzzy search
    pkgs.ripgrep # content fuzzy search
    pkgs.zk # Zettelkasten (limited support)
    pkgs.fd # Required by a Telescope plugin (?)
    pkgs.stdenv.cc.cc.lib

    # Language-specific stuffs
    pkgs.sumneko-lua-language-server
    pkgs.rust-analyzer
    rust_pkgs
    pkgs.evcxr # Rust REPL for Conjure!

    # Python3 as alternative to bash scripts :^)
    # (pkgs.python310Full.withPackages (pypkgs: [
    #   # python-lsp-server's dependencies is absolutely astronomous
    #   # pypkgs.python-lsp-server # python-lsp. Now we'll have to tell mason to look for this
    #   pypkgs.pynvim # nvim provider
    #   pypkgs.ujson  # pylsp seems to rely on this. satisfy it lol
    # ]))
  ];
in
{
  options.base.neovim = {
    enable = lib.mkOption {
      default = true;
      description = "enable personalized neovim as default editor";
      type = lib.types.bool;
      example = false;
    };
  };
  config = lib.mkIf config.base.neovim.enable {
    programs.neovim = {
      enable = true;
      package = my_neovim;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPackages = nvim_pkgs;
      # only for here for archive-documentation
      # extraPython3Packages = (pypkgs: [
      #   # pypkgs.python-lsp-server
      #   pypkgs.ujson
      # ]);
      # I use vim-plug, so I probably don't require packaging
      # extraConfig actually writes to init-home-manager.vim (not lua)
      # https://github.com/nix-community/home-manager/pull/3287
      # extraConfig = builtins.readFile "${proj_root}/neovim/init.lua";
    };
    home.packages = nvim_pkgs;
  };
}
