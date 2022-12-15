# This module aims to be merge (not inject/override) with top-level pkgs to provide
# personalized/custom packages
# For utility functions that aids with development of this whole monorepo,
# go into ../lib.
{ pkgs
, lib # extended lib from ../lib
, naersk # rust packages
, ...
}@pkgs_input:
lib.exportWithInputs [
  ./nixgl
  ./neovim
  ./cargo-bacon
] pkgs_input
