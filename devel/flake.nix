{
  description = "My development flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    programs.git = {
      enable = true;
    };
    programs.zsh = {
          enable = true;
          shellAliases = {
          	# list lists
          	ll = "ls -l";
          	update = "sudo nixos-rebuild switch";
          };
          history = {
          	size = 10000;
          	path = "${config.xdg.dataHome}/zsh/history";
          };
    };
  };
}
