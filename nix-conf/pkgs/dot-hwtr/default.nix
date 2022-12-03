{ pkgs, lib, ... }@pkgs_input: pkgs.stdenv.mkDerivation {
    name = "dot-hwtr";
    native
}
