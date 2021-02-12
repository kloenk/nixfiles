{ config, lib, pkgs, inputs, ... }:
let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: (lib.hasPrefix "add_header" line && !(lib.hasInfix "X-Frame-Options" line)))
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));

  map = pkgs.fetchFromGitHub {
          owner = "holbeh";
          repo = "office-map";
          rev = "V0.1.0";
          sha256 = "sha256-rjDnv07MYNIzZqyQyiaHYeaEWyqh8Qk5AlqVTxg1xSE=";
        } + "/";
in {

  nixpkgs.overlays = [ inputs.event_start.overlay ];

  services.nginx.virtualHosts = {
    "event.unterbachersee.de" = {
      locations."/robots.txt".return = "200 \"User-agent: *\\nDisallow: /\\n\"";
      enableACME = true;
      forceSSL = true;
      root = pkgs.event_start;

      extraConfig = ''
        ${commonHeaders}
        add_header Cache-Control $cacheable_types;
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors https://world.event.unterbachersee.de/; object-src 'none'" always;
        add_header X-Frame-Options "*" always;
      '';
      locations."/map/" = {
        alias = map;
        extraConfig = ''
          ${commonHeaders}
          add_header Cache-Control $cacheable_types;
          add_header X-Frame-Options "*" always;
          add_header Access-Control-Allow-Origin "*" always;
          add_header Content-Security-Policy "default-src 'self'; frame-ancestors https://world.event.unterbachersee.de/; object-src 'none'" always;
        '';
      };
    };
  };
}
