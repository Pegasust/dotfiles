# This module aims to be merge (not inject/override) with top-level pkgs to provide
# personalized/custom packages
{ pkgs, lib, ... }@pkgs_input: {
  dot-hwtr = import "./dot-hwtr" pkgs_input;
}
