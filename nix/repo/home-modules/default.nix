# This is an interface for home-profiles and should not contain opinionated
# configurations. It should provide alternative configurations, aggregates
# or new configurations
_imports @ {
  inputs,
  cell,
}: let
  namespace = "repo";
  imports = _imports // {inherit namespace;};
in {
  git = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config."${namespace}".git;
    baseAliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      sts = "status";
      co = "checkout";
      b = "branch";
    };
    default-user = "Pegasust";
    default-email = "pegasucksgg@gmail.com";
  in {
    options."${namespace}".git = {
      aliases = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        example = baseAliases;
        description = ''
          Additional git aliases. This settings comes with base configuration.
          Redeclaring the base config will override the values.
        ''; # TODO: Add baseAliases as string here (builtins.toString doesn't work)
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = default-user;
        description = "Git username that appears on commits";
        example = default-user;
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = default-email;
        example = default-email;
        description = "Git email that appears on commits";
      };
      ignores = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".vscode" # vscode settings
          ".direnv" # .envrc cached outputs
          ".DS_Store" # MacOS users, amrite
        ];
        description = ''
          .gitignore patterns that are applied in every "${namespace}"sitory.
          This is useful for IDE-specific settings.
        '';
        example = [".direnv" "node_modules"];
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enables git
        '';
        example = false;
      };
      credentialCacheTimeoutSeconds = lib.mkOption {
        type = lib.types.int;
        default = 3000;
        description = "Credential cache (in-memory store) for Git in seconds.";
        example = 3000;
      };
    };
    # TODO : anyway to override configuration?
    # idk wtf I was thinking about. there is no context in this question
    config.programs.git = {
      inherit (cfg) enable ignores;
      userName = cfg.name;
      userEmail = cfg.email;
      aliases = baseAliases // cfg.aliases;
      extraConfig = {
        # TODO: in the case of darwin, git always open up the built-in keychain.
        # possibly something we can't really control since we don't have access to `nix-darwin`
        credential.helper = "cache --timeout=${builtins.toString cfg.credentialCacheTimeoutSeconds}";
      };
      lfs.enable = true;
    };
  };

  alacritty = {
    config,
    lib,
    ...
  }: let
    inherit (inputs.cells.repo.lib) fromYAML;
    cfg = config."${namespace}".alacritty;
  in {
    options."${namespace}".alacritty = {
      font.family = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = ''
          The font family for Alacritty
        '';
        example = "DroidSansMono NF";
      };
      font.size = lib.mkOption {
        type = lib.types.nullOr lib.types.number;
        default = 11.0;
        description = ''
          The default font size for Alacritty. This is probably measured in px.
        '';
        example = 7.0;
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enables alacritty
        '';
        example = true;
      };
      config-path = lib.mkOption {
        type = lib.types.path;
        description = "Path to alacritty yaml";
        default = null;
        example = "./config/alacritty.yaml";
      };
    };
    config.programs.alacritty = {
      enable = cfg.enable;
      settings = let
        actualConfig =
          if cfg.config-path != null
          then fromYAML (builtins.readFile cfg.config-path)
          else {};
      in
        lib.recursiveUpdate actualConfig {
          font.normal.family = lib.mkIf (cfg.font.family != null) cfg.font.family;
          font.size = lib.mkIf (cfg.font.size != null) cfg.font.size;
        };
    };
  };

  # TODO: chromium is not really supported on darwin
  private_chromium = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config."${namespace}".private_chromium;
  in {
    options."${namespace}".private_chromium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = ''
          Enable extremely lightweight chromium with vimium plugin
        '';
      };
    };
    config = lib.mkIf (cfg.enable) {
      # home.packages = [pkgs.ungoogled-chromium];
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
        extensions = let
          # TODO: how about a chrome extension registry?
          mkChromiumExtForVersion = browserVersion: {
            id,
            sha256,
            extVersion,
            ...
          }: {
            inherit id;
            crxPath = builtins.fetchurl {
              url =
                "https://clients2.google.com/service/update2/crx"
                + "?response=redirect"
                + "&acceptformat=crx2,crx3"
                + "&prodversion=${browserVersion}"
                + "&x=id%3D${id}%26installsource%3Dondemand%26uc";
              name = "${id}.crx";
              inherit sha256;
            };
            version = extVersion;
          };
          mkChromiumExt = mkChromiumExtForVersion (lib.versions.major pkgs.ungoogled-chromium.version);
        in [
          # vimium
          (mkChromiumExt {
            id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            sha256 = "00qhbs41gx71q026xaflgwzzridfw1sx3i9yah45cyawv8q7ziic";
            extVersion = "1.67.4";
          })
        ];
      };
    };
  };

  darwin-spotlight = {
    lib,
    pkgs,
    config,
    ...
  }: {
    # This patch exists since Darwin's search bar requires solid apps and not
    # symlinked
    # TODO: QA
    # - [x] works for base case
    # - [x] works for repeated case
    # - [ ] works after base case, then removed
    # - [ ] works for repeated case, then removed

    # Copy GUI apps to "~/Applications/Home Manager Apps"
    # Based on this comment: https://github.com/nix-community/home-manager/issues/1341#issuecomment-778820334
    home.activation.patch-spotlight =
      if pkgs.stdenv.isDarwin
      then let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          # Install MacOS applications to the user environment.
          HM_APPS="$HOME/Applications/Home Manager Apps"
          # Reset current state
          if [ -e "$HM_APPS" ]; then
            $DRY_RUN_CMD mv "$HM_APPS" "$HM_APPS.$(date +%Y%m%d%H%M%S)"
          fi
          $DRY_RUN_CMD mkdir -p "$HM_APPS"
          # .app dirs need to be actual directories for Finder to detect them as Apps.
          # In the env of Apps we build, the .apps are symlinks. We pass all of them as
          # arguments to cp and make it dereference those using -H
          $DRY_RUN_CMD cp --archive -H --dereference ${apps}/Applications/* "$HM_APPS"
          $DRY_RUN_CMD chmod +w -R "$HM_APPS"
        ''
      else "";
    # We need this in case upstream home-manager changes the behavior of linking
    # applications
    home.activation.remove-patch-spotlight =
      if pkgs.stdenv.isDarwin
      then
        lib.hm.dag.entryBefore ["checkLinkTargets"] ''
          HM_APPS="$HOME/Applications/Home Manager Apps"
          # Reset current state
          if [ -e "$HM_APPS" ]; then
            $DRY_RUN_CMD mv "$HM_APPS" "$HM_APPS.$(date +%Y%m%d%H%M%S)"
          fi
        ''
      else "";
  };
}
