{ config, pkgs, ... }:

{
  fileSystems."/var/lib/pleroma" = {
    device = "/persist/data/pleroma";
    fsType = "none";
    options = [ "bind" ];
  };

  services.pleroma = {
    enable = true;
    domain = "pleroma.kloenk.dev";
    secretsEnvFile = config.petabyte.secrets."pleroma/secrets-env".path;
    configFile = ./config.exs;
  };
  petabyte.secrets."pleroma/secrets-env".owner = "root";

  services.nginx.virtualHosts."pleroma.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
  };
}
