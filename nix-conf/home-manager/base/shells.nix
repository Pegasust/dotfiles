# Configurations for shell stuffs.
# Should probably be decoupled even more
{ config
, proj_root
, myLib
, pkgs
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
    xdg.configFile."starship.toml".source = "${proj_root.config.path}//starship/starship.toml";
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
      extraConfig = builtins.readFile "${proj_root.config.path}/tmux/tmux.conf";
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
        plugins = [
          "git"   # git command aliases: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git#aliases
          # "sudo"  # double-escape to prepend sudo  # UPDATE: just use vi-mode lol
          "command-not-found" # suggests which package to install; does not support nixos (we have solution already)
          "gitignore" # `gi list` -> `gi java >>.gitignore`
          "ripgrep"   # adds completion for `rg`
          "rust"      # compe for rustc/cargo
          # "vi-mode"   # edit promps with vi motions :)
        ];
      };
      sessionVariables = {
        # VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = true;
        # VI_MODE_SET_CURSOR = true;
        # ZVM_VI_ESCAPE_BINDKEY = "";
        ZVM_READKEY_ENGINE="$ZVM_READKEY_ENGINE_NEX";
        ZVM_KEYTIMEOUT=0.004; # 40ms, or subtly around 25 FPS. I'm a gamer :)
        ZVM_ESCAPE_KEYTIMEOUT=0.004; # 40ms, or subtly around 25 FPS. I'm a gamer :)
      };
      initExtra = (cfg.shellInitExtra or "") + ''
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      '';

    };
  };
}
