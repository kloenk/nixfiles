{ config, lib, pkgs, inputs, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));
in {
  imports = [ ./p3tr1ch0rr.nix ];

  nixpkgs.overlays = [ inputs.kloenk-cv.overlays.default ];

  services.nginx.virtualHosts = {
    "kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      root = pkgs.kloenk-www;
      locations."/public/".alias = "/persist/data/public/";
      locations."/".extraConfig = "return 301 https://kloenk.eu;";
      locations."/baz".return =
        "301 https://www.amazon.de/hz/wishlist/ls/3BJ09JA3JNCN?ref_=wl_share";

      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };
    "kloenk.eu" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      root = pkgs.kloenk-www;
      locations."= /.well-known/matrix/client" = let
        client = {
          "m.homeserver" = { base_url = "https://matrix.kloenk.eu"; };
          "org.matrix.msc3575.proxy" = { url = "https://matrix.kloenk.eu"; };
        };
      in {
        root = pkgs.writeTextDir ".well-known/matrix/client"
          "${builtins.toJSON client}";
        extraConfig = config.services.nginx.virtualHosts."kloenk.eu".extraConfig
          + ''
            default_type application/json;
            ${commonHeaders}
            add_header "Access-Control-Allow-Origin" "*";
            add_header "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS";
            add_header "Access-Control-Allow-Headers" "Origin, X-Requested-With, Content-Type, Accept, Authorization";
          '';
      };
      locations."= /.well-known/matrix/server" =
        let server = { "m.server" = "matrix.kloenk.eu:443"; };
        in {
          root = pkgs.writeTextDir ".well-known/matrix/server"
            "${builtins.toJSON server}";
          extraConfig =
            config.services.nginx.virtualHosts."kloenk.eu".extraConfig + ''
              default_type application/json;
              ${commonHeaders}
              add_header "Access-Control-Allow-Origin" "*";
              add_header "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS";
              add_header "Access-Control-Allow-Headers" "Origin, X-Requested-With, Content-Type, Accept, Authorization";
            '';

        };
      locations."/public/".alias = "/persist/data/public/";

      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };

    "kloenk.de" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      root = pkgs.kloenk-www;
      locations."/public/".alias = "/persist/data/public/";
      locations."/".extraConfig = "return 301 https://kloenk.eu;";
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };

    "cv.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      root = pkgs.runCommandNoCC "cv.kloenk.dev" { } ''
        mkdir $out
        cp ${pkgs.kloenk-cv}/cv.pdf $out/index.pdf
      '';
      locations."/".index = "index.pdf";
    };

    /* "matrixcore.dev" = {
         enableACME = true;
         forceSSL = true;
         root = "/persist/data/matrixcore.dev";
       };
    */
  };
}
