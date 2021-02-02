{ config, lib, pkgs, ... }:
let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));
in {
  services.nginx.virtualHosts = {
    "krueger70.trudeltiere.de" = {
      enableACME = true;
      forceSSL = true;
      root = pkgs.krueger70;
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };
  };
}
