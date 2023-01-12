{config, pkgs, lib}:
          let
            gpu_pkgs = [ pkgs.clinfo pkgs.lshw pkgs.glxinfo pkgs.pciutils pkgs.vulkan-tools ];
            gpu_conf = {
              # openCL
              hardware.opengl = {
                enable = true;
                extraPackages = let 
                  inherit (pkgs) rocm-opencl-icd rocm-opencl-runtime;
                  in [rocm-opencl-icd rocm-opencl-runtime];
                # Vulkan
                driSupport = true;
                driSupport32Bit = true;
                package = pkgs.mesa.drivers;
                package32 = pkgs.pkgsi686Linux.mesa.drivers;
              };
            };
            in;
