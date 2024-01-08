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
}
