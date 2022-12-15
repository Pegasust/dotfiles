{ 
    mkModuleArgs = import ./mkModuleArgs.nix;
    modules = [
        ./alacritty.nix
        ./git.nix
        ./ssh.nix
        ./shells.nix
        {
            config.programs.home-manager.enable = true;
        }
    ];
}
