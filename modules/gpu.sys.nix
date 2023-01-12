{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.clinfo pkgs.lshw pkgs.glxinfo pkgs.pciutils pkgs.vulkan-tools ];
  hardware.opengl = {
    enable = true;
    extraPackages = [ pkgs.rocm-opencl-icd pkgs.rocm-opencl-runtime ];
    # Vulkan
    driSupport = true;
    driSupport32Bit = true;
    package = pkgs.mesa.drivers;
    package32 = pkgs.pkgsi686Linux.mesa.drivers;
  };
}
