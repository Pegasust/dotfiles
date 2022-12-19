{ pkgs ? import <nixpkgs> { }
, lib ? inputs.pkgs.lib
, ...
}@inputs:
lib.recursiveUpdate lib.types { }
