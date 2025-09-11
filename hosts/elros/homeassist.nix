{ ... }:

{
  services.nginx.virtualHosts."home.elros.net.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebSockets = true;
      proxyPass = "http://10.84.19.4:8123";
    };
  };
}
