{
  # Enable sound. (pulse audio)
  sound.enable = true;
  programs.dconf.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.extraConfig = "load-module module-combine-sink";
}
