{
  my-hydra = { config, pkgs, ... }: {
    # send email
    services.postfix = {
      enable = true;
      setSendmail = true;
    };
    # postgresql as a build queue (optimization possible?)
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      identMap = ''
        hydra-users hydra hydra
        hydra-users hydra-queue-runner hydra
        hydra-users hydra-www hydra
        hydra-users root postgres
        hydra-users postgres postgres
      '';
    };
    services.hydra = {
      enable = true;
      useSubstitutes = true;
      # hydraURL = 
    };
    networking = {
      firewall = {
        allowedTCPPorts = [ config.services.hydra.port ];
      };
    };
  };
}
