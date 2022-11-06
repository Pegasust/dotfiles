{ config, pkgs,... }:
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = [pkgs.htop pkgs.ripgrep];
  home.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;

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
  xdg.configFile."nvim/init.lua".text = builtins.readFile ../neovim/init.lua;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      ll = "ls -l";
      nix-rebuild = "sudo nixos-rebuild switch";
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
      a="add"; c="commit"; ca="commit --ammend"; cm="commit-m";
      lol="log --graph --decorate --pretty=oneline --abbrev-commit";
      lola="log --grpah --decorate --pretty-oneline --abbrev-commit --all";
    };
    extraConfig = {
      merge = {tool="vimdiff"; conflictstyle="diff3";};
    };
    # why is this no longer valid?
    # pull = { rebase=true; };
  };
}
