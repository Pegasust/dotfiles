{lib,...}@inputs: let
config = {
  hungtr.metadata = {
  };
  "hungtr@bao".metadata = {
    ssh_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+1+gps6phbZboIb9fH51VNPUCkhSSOAbkI3tq3Ou0Z";
  };
};
in {
  homeConfigurations = {};
  pubKeys = lib.getPubkey config;
}
