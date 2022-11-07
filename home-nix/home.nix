{ config, pkgs,... }:
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = [
    pkgs.htop pkgs.ripgrep pkgs.gcc pkgs.fd pkgs.zk pkgs.unzip 
    pkgs.rustc pkgs.cargo pkgs.nodejs-18_x
  ];
  home.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;

  ## Configs ## 
  xdg.configFile."nvim/init.lua".text = builtins.readFile ../neovim/init.lua;
  xdg.configFile."starship.toml".text = builtins.readFile ../starship/starship.toml;

  ## Programs ##
  programs.alacritty = {
    enable = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../tmux/.tmux.conf;
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
    # I use vim-plug, so I probably don't require packaging
    # extraConfig actually writes to init-home-manager.vim (not lua)
    # https://github.com/nix-community/home-manager/pull/3287
    # extraConfig = builtins.readFile ../neovim/init.lua;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      nix-rebuild = "sudo nixos-rebuild switch";
      hm-switch = "home-manager switch --flake";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "command-not-found" "gitignore" "ripgrep" "rust" ];
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    aliases = {
      a="add"; c="commit"; ca="commit --ammend"; cm="commit -m";
      lol="log --graph --decorate --pretty=oneline --abbrev-commit";
      lola="log --graph --decorate --pretty=oneline --abbrev-commit --all";
      sts="status";
    };
    extraConfig = {
      merge = {tool="vimdiff"; conflictstyle="diff3";};
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
