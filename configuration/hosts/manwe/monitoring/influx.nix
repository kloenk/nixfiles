{ lib, pkgs, config, ... }:

let
  hosts = import ../.. { };

  nginxExtraConfig = ''
    allow 2a01:598:90a2:3090::/64;
    allow 80.187.100.208/32;
    allow 192.168.242.0/24;
    allow 2a0f:4ac4:42:f144::/64;
    allow 2a0f:4ac4:42::/48;

    ${config.services.nginx.virtualHosts."${config.networking.hostName}.kloenk.dev".locations."/node-exporter/".extraConfig}
  '';
in {
  fileSystems."/var/lib/influxdb2" = {
    device = "/persist/data/influxdb2";
    fsType = "none";
    options = [ "bind" ];
  };

  services.influxdb2 = {
    enable = true;
    settings = {

    };
  };

  services.grafana.provision.datasources = [
    {
      type = "influx";
      name = "influx";
      access = "proxy";
      url = "http://127.0.0.1:8086/";
      jsonData = {
        version = "Flux";
        tlsSkipVerify = true;
      };
    }
  ];
}