# This is a nix module, with an additional wrapper from home-manager
# myHome, myLib is injected from extraSpecialArgs in flake.nix
# This file represents the base settings for each machine
# Additional configurations goes to profiles/<user>
# or inlined in flake.nix
{ config # Represents the realized final configuration
, pkgs # This is by default just ``= import <nixpkgs>{}`
, myHome
, myLib
, option # The options we're given, this might be useful for typesafety?
, proj_root
, ...
}:
let
  nvim_pkgs = [
    # Yes, I desperately want neovim to work out-of-the-box without flake.nix for now
    # I want at least python LSP to work everywhere because it's basically
    # an alternative to bash script when I move to OpenColo
    # pkgs.gccStdenv
    pkgs.gcc
    pkgs.tree-sitter
    pkgs.fzf  # file name fuzzy search
    pkgs.sumneko-lua-language-server
    pkgs.ripgrep  # content fuzzy search
    pkgs.zk  # Zettelkasten (limited support)
    pkgs.fd  # Required by a Telescope plugin (?)
    pkgs.stdenv.cc.cc.lib
    rust_pkgs
    pkgs.rust-analyzer
    # Python3 as alternative to bash scripts :^)
    # (pkgs.python310Full.withPackages (pypkgs: [
    #   # python-lsp-server's dependencies is absolutely astronomous
    #   # pypkgs.python-lsp-server # python-lsp. Now we'll have to tell mason to look for this
    #   pypkgs.pynvim # nvim provider
    #   pypkgs.ujson  # pylsp seems to rely on this. satisfy it lol
    # ]))
  ];
  rust_pkgs = (pkgs.rust-bin.selectLatestNightlyWith
    (
      toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" ];
      }
    ));
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
  inherit (myLib) fromYaml;
in
{
  home = {
    username = myHome.username;
    homeDirectory = myHome.homeDirectory;
    stateVersion = myHome.stateVersion or "22.05";
  };
  home.packages = pkgs.lib.unique ([
    # pkgs.ncdu
    pkgs.rclone   # cloud file operations
    pkgs.htop     # system diagnostics in CLI
    pkgs.ripgrep  # content fuzzy search
    pkgs.unzip    # compression
    pkgs.zip      # compression

    # cool utilities
    pkgs.yq       # Yaml adaptor for jq (only pretty print, little query)
    pkgs.xorg.xclock # TODO: only include if have GL # For testing GL installation
    pkgs.logseq # TODO: only include if have GL # Obsidian alt
    pkgs.mosh # Parsec for SSH
    # pkgs.nixops_unstable # nixops v2 # insecure for now
    pkgs.lynx # Web browser at your local terminal

    # Personal management
    pkgs.keepass  # password manager. wish there is a keepass-query

    # pkgs.tailscale # VPC;; This should be installed in system-nix
    pkgs.python310 # dev packages should be in project
    # pkgs.python310.numpy
    # pkgs.python310Packages.tensorflow
    # pkgs.python310Packages.scikit-learn
  ] ++ (myHome.packages or [ ]) 
  # ++ nvim_pkgs
  );

  ## Configs ## 
  xdg.configFile."nvim/init.lua".source = "${proj_root.config.path}//neovim/init.lua";
  xdg.configFile."zk/config.toml".source = "${proj_root.config.path}//zk/config.toml";

  ## Programs ##
  programs.jq = {
    enable = true;
  };
  # TODO: override the original package, inject tree-sitter and stuffs
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
  # not exist in home-manager
  # have to do it at system level
  # services.ntp.enable = true; # automatic time
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
