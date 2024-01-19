{ config, ... }:

{
  fileSystems."/var/lib/owncast" = {
    device = "/persist/data/owncast";
    fsType = "none";
    options = [ "bind" ];
  };

  services.owncast = {
    enable = true;
    openFirewall = true;
    port = 52199;
  };

  services.nginx.virtualHosts."live.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.owncast.port}/";
      proxyWebsockets = true;
    };
  };
}
