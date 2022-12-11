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
, ...
}:
let
  nvim_pkgs = [
    # Yes, I desperately want neovim to work out-of-the-box without flake.nix for now
    # I want at least python LSP to work everywhere because it's basically
    # an alternative to bash script when I move to OpenColo
    pkgs.gccStdenv
    pkgs.gcc
    pkgs.tree-sitter
    pkgs.ripgrep
    pkgs.fzf
    # pkgs.sumneko-lua-language-server
    pkgs.ripgrep
    pkgs.zk
    pkgs.fd
    pkgs.stdenv.cc.cc.lib
    # Python3 as alternative to bash scripts :^)
    # (pkgs.python310Full.withPackages (pypkgs: [
    #   # python-lsp-server's dependencies is absolutely astronomous
    #   # pypkgs.python-lsp-server # python-lsp. Now we'll have to tell mason to look for this
    #   pypkgs.pynvim # nvim provider
    #   pypkgs.ujson  # pylsp seems to rely on this. satisfy it lol
    # ]))
  ];
  proj_root = builtins.toString ./../..;
  inherit (myLib) fromYaml;
in
{
  home = {
    username = myHome.username;
    homeDirectory = myHome.homeDirectory;
    stateVersion = myHome.stateVersion or "22.05";
  };
  home.packages = pkgs.lib.unique ([
    pkgs.ncdu
    pkgs.htop
    pkgs.ripgrep
    pkgs.unzip
    pkgs.zip

    # cool utilities
    pkgs.yq # Yaml adaptor for jq (only pretty print, little query)
    pkgs.xorg.xclock # TODO: only include if have GL # For testing GL installation
    pkgs.logseq # TODO: only include if have GL # Obsidian alt
    pkgs.mosh # Parsec for SSH
    pkgs.nixops_unstable # nixops v2
    pkgs.lynx # Web browser at your local terminal

    # pkgs.tailscale # VPC;; This should be installed in system-nix
    pkgs.python310 # dev packages should be in jk
    # pkgs.python310.numpy
    # pkgs.python310Packages.tensorflow
    # pkgs.python310Packages.scikit-learn
  ] ++ (myHome.packages or [ ]) ++ nvim_pkgs);

  ## Configs ## 
  xdg.configFile."nvim/init.lua".source = "${proj_root}//neovim/init.lua";
  xdg.configFile."starship.toml".source = "${proj_root}//starship/starship.toml";
  xdg.configFile."zk/config.toml".source = "${proj_root}//zk/config.toml";

  ## Programs ##
  programs.jq = {
    enable = true;
  };
  # nix: Propagates the environment with packages and vars when enter (children of)
  # a directory with shell.nix-compatible and .envrc
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # nix-direnv.enableFlakes = true; # must remove. this will always be supported.
  };
  # z <path> as smarter cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile "${proj_root}/tmux/tmux.conf";
  };
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.home-manager.enable = true;
  programs.fzf.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    extraPackages = nvim_pkgs;
    # extraPython3Packages = (pypkgs: [
    #   # pypkgs.python-lsp-server
    #   pypkgs.ujson
    # ]);
    # I use vim-plug, so I probably don't require packaging
    # extraConfig actually writes to init-home-manager.vim (not lua)
    # https://github.com/nix-community/home-manager/pull/3287
    # extraConfig = builtins.readFile "${proj_root}/neovim/init.lua";
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = myHome.shellInitExtra or "";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      nix-rebuild = "sudo nixos-rebuild switch";
      hm-switch = "home-manager switch --flake";
    } // (myHome.shellAliases or { });
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "command-not-found" "gitignore" "ripgrep" "rust" ];
    };
    initExtra = myHome.shellInitExtra or "";
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    aliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      sts = "status";
      co = "checkout";
      b = "branch";
    };
    # No idea why this is not appearing in home-manager search
    # It's in source code, though
    userName = "pegasust";
    userEmail = "pegasucksgg@gmail.com";
    extraConfig = {
      merge = { tool = "vimdiff"; conflictstyle = "diff3"; };
    };
    ignores = [
      # vscode-related settings
      ".vscode"
      # envrc cached outputs
      ".direnv"
    ];
    extraConfig = {
      # cache credential for 50 minutes (a pomodoro session)
      credential.helper = "cache --timeout=3000";
    };
    # why is this no longer valid?
    # pull = { rebase=true; };
  };
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = builtins.readFile "${proj_root}/ssh/config";
  };
}
