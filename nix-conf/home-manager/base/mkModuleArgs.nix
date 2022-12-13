{ pkgs
, lib ? pkgs.lib
, ...
}@inputs:
let
  recursiveUpdate = lib.recursiveUpdate;
  _lib = recursiveUpdate lib (import ../../lib { inherit pkgs lib; });
in
# TODO: Unpollute inputs
recursiveUpdate inputs {
  proj_root = builtins.toString ./../../..;
  myLib = _lib;
}
