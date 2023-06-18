{proj_root, ...}: {
  age.secrets.s3fs = {
    file = "${proj_root.secrets.path}/s3fs.age";
    # mode = "600";  # owner + group only
    # owner = "hungtr";
    # group = "users";
  };
  age.secrets."s3fs.digital-garden" = {
    file = "${proj_root.secrets.path}/s3fs.digital-garden.age";
  };
  age.secrets._nhitrl_cred = {
    file = "${proj_root.secrets.path}/_nhitrl.age";
  };
  age.secrets."wifi.env" = {
    file = "${proj_root.secrets.path}/wifi.env.age";
  };
  # environment.systemPackages = [agenix.defaultPackage.x86_64-linux];
}
