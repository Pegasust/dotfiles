{pkgs
,lib
,proj_root
}:{
  # prune old builds after a while
  nix.settings.auto-optimize-store = true;
  nix.package = pkgs.nixFlakes;             # nix flakes
  nix.extraOptions = ''
    experimental=feature = nix-command flakes
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
    openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile "${proj_root}/ssh/authorized_keys");
  };
}
