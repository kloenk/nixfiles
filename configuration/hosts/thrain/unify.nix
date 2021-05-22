{ config, pkgs, ... }:
 
 {
  systemd.services.unify.serviceConfig.BindPaths = "/persist/data/unifi:/var/lib/unifi";
  systemd.services.unify.serviceConfig.ReadWritePaths = "/persist/data/unifi";

   nixpkgs.config.allowUnfree = true;
   services.unifi.enable = true;
   #services.unifi.jrePackage = pkgs.jdk;
   services.unifi.unifiPackage = pkgs.unifi;
   services.mongodb.dbpath = "/persist/data/mongo";
 
   services.nginx.virtualHosts."unifi.thrain.kloenk.dev" = {
     #enableACME = true;
     #forceSSL = true;
     locations."/" = {
       proxyPass = "https://127.0.0.1:8443/";
       proxyWebsockets = true;
       extraConfig = "proxy_ssl_verify off;";
     };
     #extraConfig = config.services.nginx.virtualHosts."${config.networking.hostName}.petabyte.dev".locations."/node-exporter/metrics".extraConfig; FIXME
   };
 
 }
