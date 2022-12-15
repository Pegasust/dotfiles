{ home-manager, lib, pkgs }@inputs: {
  # end result: homeConfigurations.hwtr = home-manager...
  homeConfig = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = base.modules ++ [
      ./home.nix
      {
        base.alacritty.font.family = "BitstreamVeraSansMono Nerd Font";
        base.shells = {
          shellAliases = {
            nixGL = "nixGLIntel";
          };
        };
      }
    ];
    extraSpecialArgs = mkModuleArgs {
      inherit pkgs;
      myHome = {
        username = "hwtr";
        homeDirectory = "/home/hwtr";
        packages = [
          pkgs.nixgl.nixGLIntel
          pkgs.postman
        ];
      };
    };
  };
}
