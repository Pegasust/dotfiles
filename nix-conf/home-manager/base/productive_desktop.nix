# A module that takes care of a GUI-ful, productive desktop environment
inputs@{ pkgs, ... }: {
  imports = [
    # slack
    ({ pkgs, ... }: {
      home.packages = [ 
        pkgs.slack
      ];
    })
    ./private_chromium.nix
  ];
}
