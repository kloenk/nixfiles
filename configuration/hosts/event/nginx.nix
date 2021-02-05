{ config, lib, pkgs, ... }:
let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: (lib.hasPrefix "add_header" line && !(lib.hasInfix "X-Frame-Options" line)))
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));
in {
  services.nginx.virtualHosts = {
    "gerry70.trudeltiere.de" = {
      enableACME = true;
      forceSSL = true;
      root = pkgs.krueger70;
      extraConfig = ''
        ${commonHeaders}
        add_header Cache-Control $cacheable_types;
      '';
    };
  };
}
