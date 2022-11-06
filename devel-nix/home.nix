# Helpful website to search for configurations: 
# https://mipmip.github.io/home-manager-option-search/
{ config, pkgs,... }:
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "22.05";
  home.packages = [pkgs.htop pkgs.wget pkgs.ripgrep];

  # allow unfree stuffs to be installed
  nixpkgs.config.allowUnfree = true;

  # define paths
  xdg.enable = true;
  programs.home-manager.enable = true;
  programs.fzf.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # I use vim-plug, so I probably don't require packaging
    extraConfig = builtins.readFile ../neovim/init.lua;
  };
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      nix-rebuild = "sudo nixos-rebuild switch";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    aliases = {
      a="add"; c="commit"; ca="commit --ammend"; cm="commit-m";
      lol="log --graph --decorate --pretty=oneline --abbrev-commit";
      lola="log --grpah --decorate --pretty-oneline --abbrev-commit --all";
    };
    extraConfig = {
      merge = {tool="vimdiff"; conflictstyle="diff3";};
    };
    # Why is this no longer valid?
    # pull = { rebase=true; };
  };
}
