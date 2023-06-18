# main module exporter for different configuration profiles
{
  pkgs,
  libs,
  ...
} @ inputs: {
  hwtr = import ./hwtr.nix;
}
