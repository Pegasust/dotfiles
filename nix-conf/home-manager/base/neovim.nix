# TODO: vim-plug and Mason supports laziness. Probably worth it to explore
# incremental dependencies based on the project
# TODO: just install these things, then symlink to mason's bin directory
#
# One thing to consider, though, /nix/store of `nix-shell` or `nix-develop`
# might be different from `home-manager`'s
{ pkgs, lib, config, proj_root, ... }:
let
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
    pkgs.rnix-lsp  # doesn't work, Mason just installs it using cargo
    pkgs.rust4cargo
    pkgs.nickel
    pkgs.lsp-nls

    pkgs.go


    # Language-specific stuffs
    pkgs.sumneko-lua-language-server
    # pkgs.python3Packages.python-lsp-server
    pkgs.nodePackages.pyright
    pkgs.python3Packages.pylint
    pkgs.python3Packages.flake8
    # pkgs.ansible-lint
    # pkgs.python38Packages.ansible
    # pkgs.ansible-language-server
    # TODO: the devShell should provide rust-analyzer so that 
    # cargo test builds binaries compatible with rust-analyzer 

    # pkgs.rust-analyzer
    # rust_pkgs
    # pkgs.evcxr # Rust REPL for Conjure!
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
      # Attempt 4: Correct way to make neovim aware of packages
      # homeConfigurations.config.programs.neovim takes UNWRAPPED neovim
      # and wraps it. 
      # Ideally, we build our own neovim and add that to config.home.packages
      # to share it with nixOS. But we don't really need to share
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
    # home.packages = nvim_pkgs;
    xdg.configFile."nvim/init.lua".source = "${proj_root.config.path}//neovim/init.lua";
  };
}
