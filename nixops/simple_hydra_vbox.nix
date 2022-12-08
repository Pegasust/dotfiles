# guide: https://qfpl.io/posts/nix/starting-simple-hydra/
{
  my-hydra = { config, pkgs, ... }: {
    deployment = {
      targetEnv = "virtualbox";
      virtualbox.memorySize = 1024; # 1 GB``
      virtualbox.vcpu = 2; # 2 vcpus :/ very limited on Linode, sorry
      virtualbox.headless = true; # no gui pls
    };
    services = {
      nixosManual.showManual = false; # save space, just no manual on our nix installation
      ntp.enable = true; # time daemon
      openssh = {
        allowSFTP = false; # Prefer using SCP because connection is less verbose (?)
        # we are going to generate rsa public key pair to machine
        passwordAuthentication = false; # client-pubkey/server-prikey or dig yourself
      };
    };
    users = {
      mutableUsers = false; # Remember Trien's Windows freeze function? this is it.
      # Yo, allow trusted users through ok?
      users.root.openssh.authorizedKeys.keyFiles = [ "ssh/authorizedKeys" ];
    };
  };
}
