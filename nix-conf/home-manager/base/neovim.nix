# TODO: vim-plug and Mason supports laziness. Probably worth it to explore incremental dependencies based on the project
# TODO: just install these things, then symlink to mason's bin directory
#
# One thing to consider, though, /nix/store of `nix-shell` or `nix-develop`
# might be different from `home-manager`'s (~/.nix_profile/bin/jq)
{
  pkgs,
  lib,
  config,
  proj_root,
  ...
}: let
  # NOTE: Add packages to nvim_pkgs instead, so that it's available at userspace
  # and is added to the path after wrapping.
  # check: nix repl `homeConfigurations.hungtr.config.programs.neovim.finalPackage.buildCommand`
  # see: :/--suffix.*PATH
  # there should be mentions of additional packages
  my_neovim = pkgs.neovim-unwrapped;
  nvim_pkgs =
    [
      # pkgs.gccStdenv
      # pkgs.tree-sitter
      pkgs.fzf # file name fuzzy search
      pkgs.ripgrep # content fuzzy search
      pkgs.fd # Required by a Telescope plugin (?)
      pkgs.rnix-lsp # doesn't work, Mason just installs it using cargo
      pkgs.rust4cargo
      pkgs.nickel
      pkgs.nls

      pkgs.go # doesn't work, Mason installs from runtime path

      # Language-specific stuffs
      pkgs.sumneko-lua-language-server
      # pkgs.python3Packages.python-lsp-server
      pkgs.nodePackages.pyright
      pkgs.python3Packages.pylint
      pkgs.python3Packages.flake8
      # FIXME: installing ansible from here just doesn't work :/
      # pkgs.ansible-lint
      # pkgs.python38Packages.ansible
      # pkgs.ansible-language-server
      # TODO: the devShell should provide rust-analyzer so that
      # cargo test builds binaries compatible with rust-analyzer

      # pkgs.rust-analyzer
      # rust_pkgs
      # pkgs.evcxr # Rust REPL for Conjure!
    ]
    ++ lib.optionals (pkgs.stdenv.isDarwin) (
      let
        inherit (pkgs.darwin.apple_sdk.frameworks) System CoreFoundation;
      in [
        System
        CoreFoundation
      ]
    );
in {
  options.base.neovim = {
    enable = lib.mkOption {
      default = true;
      description = "enable personalized neovim as default editor";
      type = lib.types.bool;
      example = false;
      f = let
        adder = {
          __functor = self: arg:
            if builtins.isInt arg
            then self // {x = self.x + arg;}
            else self.x;
          x = 0;
        };
      in {
        what = adder 1 2 3 {};
      };
    };
  };
  config = lib.mkIf config.base.neovim.enable {
    # home-manager
    programs.neovim = {
      enable = true;
      package = my_neovim;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPackages = nvim_pkgs;
      extraLuaConfig = builtins.readFile "${proj_root.config.path}//neovim/init.lua";
      plugins = let
        inherit
          (pkgs.vimPlugins)
          plenary-nvim
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-treesitter-context
          telescope-fzf-native-nvim
          telescope-file-browser-nvim
          telescope-nvim
          nvim-lspconfig
          gruvbox-community
          neodev-nvim
          cmp-nvim-lsp
          cmp-path
          cmp-buffer
          cmp-cmdline
          nvim-cmp
          lspkind-nvim
          nvim-autopairs
          nvim-ts-autotag
          guess-indent-nvim
          harpoon
          zk-nvim
          luasnip
          fidget-nvim
          rust-tools-nvim
          cmp_luasnip
          gitsigns-nvim
          indent-blankline-nvim
          lualine-nvim
          mason-lspconfig-nvim
          mason-nvim
          neogit
          nlua-nvim
          nvim-jqx
          nvim-surround
          nvim-web-devicons
          playground
          todo-comments-nvim
          trouble-nvim
          vim-dispatch
          vim-dispatch-neovim
          vim-fugitive
          vim-jack-in
          sg-nvim
          ;
      in [
        plenary-nvim
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        telescope-nvim
        nvim-lspconfig
        gruvbox-community
        neodev-nvim
        cmp-nvim-lsp
        cmp-path
        cmp-buffer
        cmp-cmdline
        nvim-cmp
        lspkind-nvim
        nvim-autopairs
        nvim-ts-autotag
        guess-indent-nvim
        harpoon
        zk-nvim
        luasnip
        nvim-treesitter-context
        fidget-nvim
        rust-tools-nvim

        cmp_luasnip
        gitsigns-nvim
        indent-blankline-nvim
        lualine-nvim
        mason-lspconfig-nvim
        mason-nvim
        neogit
        nlua-nvim
        nvim-jqx
        nvim-surround
        nvim-web-devicons
        playground
        todo-comments-nvim
        trouble-nvim
        vim-dispatch
        vim-dispatch-neovim
        vim-fugitive
        vim-jack-in
        sg-nvim
      ];
    };
    # home.packages = nvim_pkgs;
  };
}
