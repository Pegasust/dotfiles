{ pkgs
, lib
, naersk
,...
}@pkgs_input: {
    deriv = pkgs.rustPlatform.buildRustPackage rec {
      pname = "bacon";
    };
}
