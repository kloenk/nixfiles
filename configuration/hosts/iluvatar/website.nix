{ config, lib, inputs, pkgs, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));

  apple_assoc = {
    applinks = {
      apps = [];
      details = [
        {
          appIDs = [
            "7J4U792NQT.im.vector.app"
            "257L85Q939.chat.schildi.desktop"
          ];
          appID = "7J4U792NQT.im.vector.app";
          components = [
            {
              "#" = "/*";
            }
          ];
          paths = [
            "/*"
            "/#/*"
          ];
        }
        {
          appID = "257L85Q939.chat.schildi.desktop";
          components = [
            {
              "#" = "/*";
            }
          ];
          paths = [
            "/*"
            "/#/*"
          ];
        }
      ];
    };
    webcredentials = {
      apps = [
        "7J4U792NQT.im.vector.app"
      ];
    };
  };
in {
  services.nginx.virtualHosts = {
    /*"lexbeserious.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.website;
      locations."/".index = "lexbeserious.html";
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };*/
    "kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.website;
      locations."/public/".alias = "/persist/data/public/";
      locations."/baz".return = "301 https://www.amazon.de/hz/wishlist/ls/3BJ09JA3JNCN?ref_=wl_share";
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };
    "kloenk.de" = {
      enableACME = true;
      forceSSL = true;
      root = inputs.website;
      locations."/public/".alias = "/persist/data/public/";
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };
    "iluvatar.kloenk.de" = {
      locations."/public/".alias =
        config.services.nginx.virtualHosts."kloenk.de".locations."/public/".alias;
    };
    "dev.matrix-push.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:5000/";
    };

    "mx-redir.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      root = pkgs.matrix-to;
      locations."= /.well-known/apple-app-site-association" = {
        root = pkgs.writeTextDir ".well-known/apple-app-site-association" "${builtins.toJSON apple_assoc}";
        extraConfig = ''
          ${commonHeaders}
          default_type application/json;
          add_header Access-Control-Allow-Origin "*";
          add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
          add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization";
        '';
      };
    };
  };
}
