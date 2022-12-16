let
  # these are configured to work with home-manager with some mutations that are
  # reconfigurable
  homeModules = [
    ./alacritty.nix
    ./git.nix
    ./ssh.nix
    ./shells.nix
    ./neovim.nix
    ./home.req.nix
    {
      config.programs.home-manager.enable = true;
    }
  ];
  # These are the modules that should be used only in nixosConfigurations
  # since it relies on root permission to run
  serviceModules = [
    ./gitea.service.nix
    ./vault.service.nix
    ./tailscale.service.nix
  ];
  allModules = homeModules ++ serviceModules;
in
{
  mkModuleArgs = import ./mkModuleArgs.nix;
  modules = allModules;
  inherit homeModules serviceModules;
}
