{ config, pkgs, lib, ... }:

{
  fileSystems."/var/lib/bitwarden_rs" = {
    device = "/persist/data/bitwarden_rs";
    fsType = "none";
    options = [ "bind" ];
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/bitwarden_rs/backup";
    config = {
      domain = "https://bitwarden.kloenk.de";
      signupsAllowed = false;
      rocketPort = config.k.ports.vaultwarden;
      rocketLog = "critical";
    };
  };

  services.nginx.virtualHosts."bitwarden.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    # Allow large attachments
    extraConfig = "client_max_body_size 128M;";
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.k.ports.vaultwarden}/";
  };
  services.nginx.virtualHosts."bitwarden.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    # Allow large attachments
    extraConfig = "client_max_body_size 128M;";
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.k.ports.vaultwarden}/";
  };
}
