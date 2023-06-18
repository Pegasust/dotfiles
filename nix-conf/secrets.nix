let
  # user-specific (~/.ssh/id_ed25519.pub)
  users = {
    "hungtr@bao" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+1+gps6phbZboIb9fH51VNPUCkhSSOAbkI3tq3Ou0Z";
  };
  # System-specific settings (/etc/ssh/ssh_hsot_ed25519_key.pub)
  systems = {
    "bao" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBuAaAE7TiQmMH300VRj/pYCri1qPmHjd+y9aX2J0Fs";
  };
  all = users // systems;
  # stands for calculus
  c_ = builtins;
in {
  "system/secrets/s3fs.age".publicKeys = c_.attrValues all;
  "system/secrets/s3fs.digital-garden.age".publicKeys = c_.attrValues all;
  "system/secrets/_nhitrl.age".publicKeys = c_.attrValues all;
}
