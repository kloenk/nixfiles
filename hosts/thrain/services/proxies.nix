{ ... }:

{
  services.nginx.virtualHosts."netbox-nas.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.144:8127/"; };
  };

  services.nginx.virtualHosts."nas.net.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "https://192.168.178.144:5001/";
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };

  services.nginx.virtualHosts."fritz.net.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.1"; };
  };

  services.nginx.virtualHosts."eib.net.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = { proxyPass = "http://192.168.178.44"; };
  };

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

  services.nginx.virtualHosts."studio-switch.mgmt.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://192.168.44.4";
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };

  services.nginx.virtualHosts."dachboden-switch.mgmt.thrain.net.kloenk.de" = {
    enableACME = true;
    forceSSL = true;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://192.168.44.6";
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };
}
