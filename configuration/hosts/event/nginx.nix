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
        add_header X-Frame-Options "*" always;
      '';

      locations."/map/" = {
        alias = (pkgs.fetchFromGitHub {
          owner = "holbeh";
          repo = "office-map";
          rev = "949aa0f567b58a9cbcb13ae4379bd88dcfc597ba";
          sha256 = "sha256-uIaYf8rc66dy21asA2D3lIJXrHjJfqySwscZEu4LHAE=";
        } + "/");
        extraConfig = ''
           ${commonHeaders}
          add_header Cache-Control $cacheable_types;
          add_header X-Frame-Options "*" always;
          add_header Access-Control-Allow-Origin "*" always;
        '';
      };
    };
  };
}
