# myHome is injected from extraSpecialArgs in flake.nix
{ config
, pkgs
, myHome
, myLib
, extraSSH
, ...
}:
{
  home = {
    username = myHome.username;
    homeDirectory = myHome.homeDirectory;
    stateVersion = myHome.stateVersion or "22.05";
  };
  home.packages = [
    pkgs.htop
    pkgs.ripgrep
    pkgs.gcc
    pkgs.fd
    pkgs.zk
    pkgs.unzip
    pkgs.rust-bin.nightly.latest.default
    pkgs.nodejs-18_x
    pkgs.rust-analyzer
    pkgs.stdenv.cc.cc.lib
    pkgs.yq
    pkgs.python39Full
    pkgs.xorg.xclock # TODO: only include if have GL
    pkgs.logseq # TODO: only include if have GL
    pkgs.mosh
    pkgs.nixops_unstable # nixops v2
    # pkgs.python310 # dev packages should be in jk
    # pkgs.python310.numpy
    # pkgs.python310Packages.tensorflow
    # pkgs.python310Packages.scikit-learn
  ] ++ (myHome.packages or [ ]);
  nixpkgs.config.allowUnfree = true;

  ## Configs ## 
  xdg.configFile."nvim/init.lua".text = builtins.readFile ../neovim/init.lua;
  xdg.configFile."starship.toml".text = builtins.readFile ../starship/starship.toml;

  ## Programs ##
  programs.jq = {
    enable = true;
  };
  programs.alacritty = myHome.programs.alacritty or {
    enable = true;
    # settings = myLib.fromYaml (builtins.readFile ../alacritty/alacritty.yml);
  };
  # nix: Propagates the environment with packages and vars when enter (children of)
  # a directory with shell.nix-compatible and .envrc
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # z <path> as smarter cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux/tmux.conf;
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
    # I use vim-plug, so I probably don't require packaging
    # extraConfig actually writes to init-home-manager.vim (not lua)
    # https://github.com/nix-community/home-manager/pull/3287
    # extraConfig = builtins.readFile ../neovim/init.lua;
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
      ca = "commit --ammend";
      cm = "commit -m";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      sts = "status";
    };
    # No idea why this is not appearing in home-manager search
    # It's in source code, though
    userName="pegasust";
    userEmail="pegasucksgg@gmail.com";
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
      # cache credential for 10 minutes.
      credential.helper = "cache --timeout=600";
    };
    # why is this no longer valid?
    # pull = { rebase=true; };
  };
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = builtins.readFile ../ssh/config;
  };
}
