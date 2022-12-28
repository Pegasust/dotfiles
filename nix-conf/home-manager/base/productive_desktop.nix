inputs@{pkgs,...}: {
  imports = [
    # slack
    ({pkgs,...}: {
      home.packages = [pkgs.slack];
    })
    ./private_chromium.nix
  ];
}
