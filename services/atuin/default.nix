{ config, ... }:

{
  services.atuin = {
    enable = true;
    port = 61688;
    # openRegistration = true;
  };

  services.nginx.virtualHosts."atuin.kloenk.eu" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    extraConfig = "client_max_body_size 128M;";
    locations."/".proxyPass =
      "http://127.0.0.1:${toString config.services.atuin.port}/";
  };

}
