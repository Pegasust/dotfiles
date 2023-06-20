# TODO: this should use winnow with a fair matching of supported systems
{
  inputs,
  cell,
}: let
  inherit (cell) home-profiles home-modules;
  inherit (inputs) home-manager;
  pkgs = inputs.nixpkgs;

  # hm is derivation that is compatible with homeConfigurations
  home-config = {
    supported_systems,
    hm,
    tested_systems ? [],
  }:
    hm
    // {
      _supported_systems = supported_systems;
      _tested_systems = tested_systems;
    };

  base-modules = [
    home-profiles.alacritty
    home-profiles.git
    home-profiles.ssh
    home-profiles.shells
    {config.programs.home-manager.enable = true;}
    home-profiles.nix-index
    home-profiles.neovim
  ];
in {
  homeConfigurations.htran = home-config {
    supported_systems = ["aarch64-darwin" "x86_64-darwin"];
    tested_systems = ["aarch64-darwin"];
    hm = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        base-modules
        ++ [
          home-profiles.nerd_font_module
          home-profiles.git-htran
          home-profiles.dev-packages
          home-profiles.zk
          home-modules.darwin-spotlight

          {
            home.username = "htran";
            home.homeDirectory = "/Users/htran";
            home.stateVersion = "23.11";
          }
        ];
    };
  };
}
