{ ... }:

{
  services.nginx.virtualHosts."netbox-nas.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.144:8127/"; };
  };
  security.acme.certs."netbox-nas.thrain.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";

  services.nginx.virtualHosts."fritz.net.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.1"; };
  };
  security.acme.certs."fritz.net.thrain.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";

  services.nginx.virtualHosts."eib.net.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.44"; };
  };
  security.acme.certs."eib.net.thrain.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";

  services.nginx.virtualHosts."edgeswitch.mgmt.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "https://192.168.44.3";
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };
  security.acme.certs."edgeswitch.mgmt.thrain.net.kloenk.de".server =
    "https://acme.net.kloenk.de:8443/acme/acme/directory";
}
