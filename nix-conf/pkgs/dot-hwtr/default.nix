{ pkgs, lib, ... } @ pkgs_input:
pkgs.stdenv.mkDerivation {
  pname = "dot-hwtr";
  version = "0.0.1";
  src = ./../../..; # project root
  nativeBuildInputs = [
    pkgs.yq
    pkgs.jq
  ];
  buildPhase = ''
    # Translate alacritty.yml -> alacritty.json. Technically, yml is superset of json
    yq . alacritty/alacritty.yml > alacritty/alacritty.json
  '';
  installPhase = ''
    echo "Nothing to install. It should be available under $out/alacritty/alacritty.json"
    mkdir -p $out/alacritty
    cp alacritty/* $out/alacritty/
  '';
}
