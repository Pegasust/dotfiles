{ home-manager, lib, pkgs, configModule, ... }@inputs: {
  # end result: homeConfigurations.hwtr = home-manager...
  homeConfig = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = configModule.homeModules ++ [
      {
        base.alacritty.font.family = "BitstreamVeraSansMono Nerd Font";
        base.shells = {
          shellAliases = {
            nixGL = "nixGLIntel";
          };
        };
        users.users.hungtr = {
          isNormalUser = true;
          home = "/home/hungtr";
          description = "pegasust/hungtr";
          extraGroups = [ "wheel" "networkmanager" ];
        };
      }
    ];
    extraSpecialArgs = lib.mkModuleArgs {
      inherit pkgs;
      myHome = {
        packages = [
          pkgs.nixgl.nixGLIntel
          pkgs.postman
        ];
      };
    };
  };
}
