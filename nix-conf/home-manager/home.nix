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
  inherit (myLib) fromYaml;
in
{
  imports = [
    ./base/neovim.nix
  ];
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
  );

  ## Configs ## 
  xdg.configFile."nvim/init.lua".source = "${proj_root.config.path}//neovim/init.lua";
  xdg.configFile."zk/config.toml".source = "${proj_root.config.path}//zk/config.toml";

  ## Programs ##
  programs.jq = {
    enable = true;
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
