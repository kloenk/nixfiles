{ config, lib, pkgs, ... }:

let
  commonHeaders = lib.concatStringsSep "\n"
    (lib.filter (line: lib.hasPrefix "add_header" line)
      (lib.splitString "\n" config.services.nginx.commonHttpConfig));

  apple_assoc = {
    applinks = {
      apps = [ ];
      details = [
        {
          appIDs =
            [ "7J4U792NQT.im.vector.app" "257L85Q939.chat.schildi.desktop" ];
          appID = "7J4U792NQT.im.vector.app";
          components = [{ "#" = "/*"; }];
          paths = [ "/*" "/#/*" ];
        }
        {
          appID = "257L85Q939.chat.schildi.desktop";
          components = [{ "#" = "/*"; }];
          paths = [ "/*" "/#/*" ];
        }
      ];
    };
    webcredentials = { apps = [ "7J4U792NQT.im.vector.app" ]; };
  };

  p3tr_locations = {
    "/" = { return = "301 https://twitch.tv/p3tr1ch0rr"; };
    "/discord" = { return = "301 https://discord.gg/8Y9dKHq7Zr"; };
    "/kofi" = { return = "301 https://ko-fi.com/p3tr1ch0rr"; };
    "/ko-fi" = { return = "301 https://ko-fi.com/p3tr1ch0rr"; };
    "/spotify" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/musik" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/music" = { return = "301 https://open.spotify.com/user/chilsninkio"; };
    "/insta" = { return = "301 https://instagram.com/p3tr_1ch0rr"; };
  };
in {
  services.nginx.virtualHosts = {
    "kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
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
      root = pkgs.kloenk-www;
      locations."/public/".alias = "/persist/data/public/";
      locations."/".extraConfig = "return 301 https://kloenk.eu;";
      extraConfig = ''
        ${commonHeaders}
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; frame-ancestors 'none'; object-src 'none'" always;
        add_header Cache-Control $cacheable_types;
      '';
    };
    "iluvatar.kloenk.de" = {
      locations."/public/".alias =
        config.services.nginx.virtualHosts."kloenk.de".locations."/public/".alias;
    };
    "matrixcore.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "/persist/data/matrixcore.dev";
    };
    "dev.matrix-push.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:5000/";
    };

    # "mx-redir.kloenk.dev" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   root = pkgs.matrix-to;
    #   locations."= /.well-known/apple-app-site-association" = {
    #     root = pkgs.writeTextDir ".well-known/apple-app-site-association"
    #       "${builtins.toJSON apple_assoc}";
    #     extraConfig = ''
    #       ${commonHeaders}
    #       default_type application/json;
    #       add_header Access-Control-Allow-Origin "*";
    #       add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    #       add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization";
    #     '';
    #   };
    # };

    "p3tr1ch0rr.de" = {
      enableACME = true;
      forceSSL = true;
      locations = p3tr_locations;
    };
    "www.p3tr1ch0rr.de" = {
      enableACME = true;
      forceSSL = true;
      locations = p3tr_locations;
    };
  };
}
