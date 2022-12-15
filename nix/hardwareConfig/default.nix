{ lib # require extended lib
, config
, pkgs
, modulePaths
, ...
}@inputs:
# Yields {nix = import ./nyx.nix inputs; ...}
# TODO: use something that can detect .nix into a list for auto adding. Remember to filter out default.nix
lib.exportWithInputs (
  [
    ./nyx.nix
    ./Felia.nix
    ./lizzi.nix
    ./prince.nix
  ]
    inputs
)

