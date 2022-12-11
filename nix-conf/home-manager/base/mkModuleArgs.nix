{ pkgs
, lib ? pkgs.lib
, ...
}@inputs:
let
  _lib = lib // import ../../lib { inherit pkgs lib; };
in
# TODO: Unpollute inputs
inputs // {
  proj_root = builtins.toString ./../../..;
  myLib = _lib;
}
