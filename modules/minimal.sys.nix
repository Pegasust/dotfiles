{pkgs
,lib
,proj_root
,modulesPath
,...
}:{
  imports = ["${modulesPath}/profiles/minimal.nix"];
  # prune old builds after a while
  nix.settings.auto-optimise-store = true;
  nix.package = pkgs.nixFlakes;             # nix flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  programs.neovim = {
      enable = true;
      defaultEditor = true;
  };
  programs.git.enable = true;  
  environment.systemPackages = [
    pkgs.gnumake
    pkgs.wget
    pkgs.inetutils # network diag
    pkgs.mtr # network diag
    pkgs.sysstat # sys diag
  ];
  users.users.root = {
    # openssh runs in root, no? This is because port < 1024 requires root.
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile "${proj_root.configs.path}/ssh/authorized_keys");
  };
}
