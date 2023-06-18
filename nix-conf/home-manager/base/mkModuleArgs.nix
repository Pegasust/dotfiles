# Turns given inputs into the standardized shape of the inputs to configure
# custom base modules in this directory.
{
  pkgs,
  lib ? pkgs.lib,
  ...
} @ inputs: let
  recursiveUpdate = lib.recursiveUpdate;
  _lib = recursiveUpdate lib (import ../../lib {inherit pkgs lib;});
  proj_root = builtins.toString ./../../..;
in
  # TODO: Unpollute inputs
  recursiveUpdate inputs {
    proj_root = {
      path = proj_root;
      config.path = "${proj_root}/native_configs";
      scripts.path = "${proj_root}/scripts";
    };
    myLib = _lib;
  }
