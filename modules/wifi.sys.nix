{ config, ... }: {
  networking.wireless.enable = true;
  networking.wireless.environmentFile = config.age.secrets."wifi.env";
  networking.wireless.networks = {
    "Hoang Sa".psk = "@DESERT_PSK@";
    "Truong Sa".psk = "@DESERT_PSK@";
  };
}
