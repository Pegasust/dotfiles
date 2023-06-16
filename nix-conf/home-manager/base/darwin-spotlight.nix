{ lib, pkgs, config, ... }:
{
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
    if pkgs.stdenv.isDarwin then
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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
    else
      "";
  # We need this in case upstream home-manager changes the behavior of linking
  # applications
  home.activation.remove-patch-spotlight = 
    if pkgs.stdenv.isDarwin then
      lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        HM_APPS="$HOME/Applications/Home Manager Apps"
        # Reset current state
        if [ -e "$HM_APPS" ]; then
          $DRY_RUN_CMD mv "$HM_APPS" "$HM_APPS.$(date +%Y%m%d%H%M%S)"
        fi
      ''
    else
      "";
}
