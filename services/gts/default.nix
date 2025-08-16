{ config, pkgs, ... }:

let
  pleroma-fe = pkgs.pleroma-fe.override {
    be-config = {
      disableChat = true;
      loginMethod = "token";
      redirectRootNoLogin = "/users/klonk";
    };
  };
in {
  fileSystems."/var/lib/gotosocial" = {
    device = "/persist/data/gotosocial";
    fsType = "none";
    options = [ "bind" ];
  };

  services.gotosocial = {
    enable = true;
    setupPostgresqlDB = true;
    settings = {
      application-name = "kloenk tries to be social";
      landing-page-user = "klonk";
      host = "gts.kloenk.dev";
      protocol = "https";
      bind-address = "localhost";
      port = 34168;

      instance-stats-mode = "baffle"; # fuck crawlers that ignore robots.txt

      metrics-enabled = true;
    };
  };

  systemd.services.gotosocial = {
    serviceConfig.Environment = [ "OTEL_METRIX_EXPORTER=prometheus" ];
  };

  services.nginx = {
    clientMaxBodySize = "40M";
    virtualHosts."gts.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations = {
        /* "/" = {
             recommendedProxySettings = true;
             proxyWebsockets = true;
             proxyPass = "http://localhost:34168";
           };
           "@index" = {
             root = pleroma-fe;
        */
        /* extraConfig = ''
             add_header Cache-Control no-cache;
           '';
        */
        /* tryFiles = "/index.html =404";
           };
        */
        "/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://localhost:34168";
        };
        "/pleroma-fe/" = {
          root = pleroma-fe;
          tryFiles = "$uri index.html";
        };
        /* "@gts" = {
             recommendedProxySettings = true;
             proxyWebsockets = true;
             proxyPass = "http://localhost:34168";
           };
           "/api/" = {
             recommendedProxySettings = true;
             proxyWebsockets = true;
             proxyPass = "http://localhost:34168";
           };
        */
      };
    };
    virtualHosts."pleroma.gts.kloenk.dev" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations = {
        "/api/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://localhost:34168";
        };
        "/assets/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://localhost:34168";
        };
        "/oauth/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://localhost:34168";
        };
        "/auth/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://localhost:34168";
        };
        "/" = {
          root = pleroma-fe;
          tryFiles = "$uri $uri/ @index";
        };
        "@index" = {
          root = pleroma-fe;
          tryFiles = "/index.html =404";
        };
      };
    };
  };

  backups.gotosocial = {
    user = "gotosocial";
    paths = [ "/persist/data/gotosocial" ];
    postgresDatabases = [ "gotosocial" ];
  };

  services.telegraf.extraConfig.inputs = {
    prometheus = [{ urls = [ "http://localhost:9464/metrics" ]; }];
  };
}
