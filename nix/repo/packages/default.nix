{
  inputs,
  cell,
}: let
  pkgs = inputs.nixpkgs;
in {
  inherit (inputs.cells.dotfiles.packages) kpcli-py;
  kpxc = let
    inherit (pkgs) keepassxc;
  in
    pkgs.stdenv.mkDerivation {
      pname = "keepassxc-darwin";
      version = keepassxc.version;

      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        cp -r ${keepassxc}/* $out/

        ${
          if pkgs.stdenv.hostPlatform.isDarwin
          then ''
            for exe in $(find $out/Applications/KeePassXC.app/Contents/MacOS/ -type f -executable); do
              exe_name=$(basename $exe)
              ln -s $exe $out/bin/$exe_name
            done
          ''
          else ""
        }
      '';
      meta =
        keepassxc.meta
        // {
          description = "Wrapper for keepassxc and keepassxc-cli with additional Darwin-specific fixes";
        };
    };

  pixi-edit = inputs.cells.dev.packages.pixi-edit;
}
