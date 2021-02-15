{ config, lib, pkgs, ... }:

{
 systemd.services.jitsi-exporter = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.jitsiexporter}/bin/jitsiexporter -url http://127.0.0.1:8181/colibri/stats";
    };
  };

 services.jitsi-videobridge.extraProperties."org.jitsi.videobridge.rest.private.jetty.port" = "8181";

  services.nginx.virtualHosts."${config.networking.hostName}.kloenk.dev" = {
    locations."/jitsi-exporter/metrics".proxyPass = "http://127.0.0.1:9700/metrics";
  };
}
