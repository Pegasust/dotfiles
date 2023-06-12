{inputs, cell}: {
  nerd_font_module = {config, pkgs, ...}: {
    fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    ];
    base.alacritty.font.family = "Hack Nerd Font Mono";
  };
}
