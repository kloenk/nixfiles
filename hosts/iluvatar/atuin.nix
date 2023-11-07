{ config, ... }:

{
  services.atuin = {
    enable = true;
    openFirewall = false;
    port = 8987;
  };

  services.nginx.virtualHosts."atuin.kloenk.eu" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.services.atuin.port}/";
  };
}
