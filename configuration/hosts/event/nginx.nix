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

  services.nginx.commonHttpConfig = ''
    map $sent_http_content_type $cacheable_types {
      "text/html"               "public; max-age=600; must-revalidate";
      "text/plain"              "public; max-age=3600; must-revalidate";
      "application/json"        "public; max-age=60; must-revalidate";
      "text/css"                "public; max-age=15778800; immutable";
      "application/javascript"  "public; max-age=15778800; immutable";
      "font/woff2"              "public; max-age=15778800; immutable";
      "application/xml"         "public; max-age=3600; must-revalidate";
      default                   "public; max-age=1209600";
    }
  '';

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
