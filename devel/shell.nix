{ pkgs? import <nixpkgs>{}, home-manager, ...}:
with pkgs;
mkShell {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    programs.git = {
      enable = true;
    };
    programs.zsh = {
      enable = true;
      shellAliases = {
        # list lists
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };
      history = {
        size = 10000;
        path = "${home-manager.cfg.dataHome}/zsh/history";
      };
    };
}
