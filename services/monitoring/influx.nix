{ ... }:

{
  fileSystems."/var/lib/influxdb2" = {
    device = "/persist/data/influxdb2";
    fsType = "none";
    options = [ "bind" ];
  };

  services.nginx.virtualHosts."influx.kloenk.de" = {
    locations."/".proxyPass = "http://127.0.0.1:8086/";
    enableACME = true;
    forceSSL = true;
  };

  services.influxdb2 = {
    enable = true;
    settings = { };
  };
}
