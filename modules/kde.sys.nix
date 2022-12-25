{pkgs
,lib
,config
,proj_root
,agenix
}: {
  environment.noXlibs = lib.mkForce false;
}
