{
  # Sound: pipewire
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Might want to use JACK in the future
    jack.enable = true;
  };

  security.rtkit.enable = true;
}
