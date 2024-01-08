{ config, pkgs, ... }:

{
  fileSystems."/var/lib/private/uptime-kuma" = {
    device = "/persist/data/uptime-kuma";
    fsType = "none";
    options = [ "bind" ];
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "56473";
    };
  };

  services.nginx.virtualHosts."uptime.kloenk.eu" = {
    locations."/".proxyPass =
      "http://localhost:${config.services.uptime-kuma.settings.PORT}/";
    locations."/".proxyWebsockets = true;
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };
}
