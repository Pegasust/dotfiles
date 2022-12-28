{ config, pkgs, lib, ... }:
let cfg = config.base.private_chromium;
in
{
  options.base.private_chromium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enable extremely lightweight chromium with vimium plugin
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    # home.packages = [pkgs.ungoogled-chromium];
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions =
        let
          mkChromiumExtForVersion = browserVersion: { id, sha256, extVersion, ... }:
            {
              inherit id;
              crxPath = builtins.fetchurl {
                url = "https://clients2.google.com/service/update2/crx" +
                  "?response=redirect" +
                  "&acceptformat=crx2,crx3" +
                  "&prodversion=${browserVersion}" +
                  "&x=id%3D${id}%26installsource%3Dondemand%26uc";
                name = "${id}.crx";
                inherit sha256;
              };
              version = extVersion;
            };
          mkChromiumExt = mkChromiumExtForVersion (lib.versions.major pkgs.ungoogled-chromium.version);
        in
        [
          # vimium
          (mkChromiumExt {
            id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            sha256 = "00qhbs41gx71q026xaflgwzzridfw1sx3i9yah45cyawv8q7ziic";
            extVersion = "1.67.4";
          })
        ];
    };
  };
}
