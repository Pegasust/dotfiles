let
  rev = "4f6d8095fd51";
in
import (fetchTarball {
  url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
  sha256 = "14sm0bjjcmi9qmznwy3nkd2vbhj5xcshgm54a5wiprl9ssvxqw53";
})
