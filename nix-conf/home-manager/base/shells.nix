# Configurations for shell stuffs.
# Should probably be decoupled even more
{ config
, proj_root
, myLib
, ...
}:
let cfg = config.base.shells;
in
{
  options.base.shells = {
    enable = myLib.mkOption {
      type = myLib.types.bool;
      description = "Enable umbrella shell configuration";
      default = true;
      example = false;
    };
    # TODO: Support shell-specific init
    shellInitExtra = myLib.mkOption {
      type = myLib.types.str;
      description = "Extra shell init. The syntax should be sh-compliant";
      default = "";
      example = ''
        # X11 support for WSL
        export DISPLAY=$(ip route list default | awk '{print $3}'):0
        export LIBGL_ALWAYS_INDIRECT=1
      '';
    };
    shellAliases = myLib.mkOption {
      type = myLib.types.attrs;
      description = "Shell command aliases";
      default = { };
      example = {
        nixGL = "nixGLIntel";
      };
    };
  };
  config = myLib.mkIf cfg.enable {
    xdg.configFile."starship.toml".source = "${proj_root}//starship/starship.toml";
    # nix: Propagates the environment with packages and vars when enter (children of)
    # a directory with shell.nix-compatible and .envrc
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      # nix-direnv.enableFlakes = true; # must remove. this will always be supported.
    };
    # z <path> as smarter cd
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile "${proj_root}/tmux/tmux.conf";
    };
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.fzf.enable = true;
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = cfg.shellInitExtra or "";
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      shellAliases = {
        nix-rebuild = "sudo nixos-rebuild switch";
        hm-switch = "home-manager switch --flake";
      } // (cfg.shellAliases or { });
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "command-not-found" "gitignore" "ripgrep" "rust" ];
      };
      initExtra = cfg.shellInitExtra or "";
    };
  };
}
