{ lib, pkgs, config, ... }:

{
  fileSystems."/var/lib/unifi" = {
    device = "/persist/data/unifi";
    fsType = "none";
    options = [ "bind" ];
  };
  systemd.services.unifi.unitConfig.RequireMountsFor = [ "/var/lib/unifi" ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "unifi-controller" ];

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
  };

  services.nginx.virtualHosts."unifi.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8443/";
      proxyWebsockets = true;
      extraConfig = "proxy_ssl_verify off;";
    };
  };
}
