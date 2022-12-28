{ pkgs
, lib
}: {
  environment.noXlibs = lib.mkForce false;
  # TODO: wireless networking

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # KDE & Plasma 5
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5 = {
    enable = true;
    excludePackages = let plasma5 = pkgs.libsForQt5; in
      [
        plasma5.elisa # audio viewer
        plasma5.konsole # I use alacritty instaed
        plasma5.plasma-browser-integration
        plasma5.print-manager # will enable if I need
        plasma5.khelpcenter # why not just write manpages instead :(
        # plasma5.ksshaskpass   # pls just put prompts on my dear terminal
      ];
  };

  # disables KDE's setting of askpassword
  programs.ssh.askPassword = "";
  programs.ssh.enableAskPassword = false;
}
