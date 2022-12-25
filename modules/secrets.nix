{agenix
,proj_root}: {
  age.secrets.s3fs = {
    file = "${proj_root}/secrets/s3fs.age";
    # mode = "600";  # owner + group only
    # owner = "hungtr";
    # group = "users";
  };
  age.secrets."s3fs.digital-garden" = {
    file = "${proj_root}/secrets/s3fs.digital-garden.age";
  };
  age.secrets._nhitrl_cred = {
    file = "${proj_root}/secrets/_nhitrl.age";
  };
  environment.systemPackages = [agenix.defaultPackage.x86_64-linux];
}
