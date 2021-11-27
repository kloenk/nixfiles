{ config, pkgs, lib, ... }:

{
  services.restya-board = {
    enable = true;
    virtualHost = {
      serverName = "restya.kloenk.dev";
      
    };
  };

  services.nginx.virtualHosts."restya.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
  };
}
