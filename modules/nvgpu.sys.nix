{config,...}: {
  imports = [./gpu.sys.nix];
  nixpkgs.config.allowUnfree = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
