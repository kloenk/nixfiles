{ lib, pkgs, config, ... }:

{
  systemd.services.grafana.after = [ "influx.service" ];
  systemd.services.grafana.serviceConfig.EnvironmentFile =
    [ config.sops.secrets."monitoring/grafana/env".path ];
  sops.secrets."monitoring/grafana/env".owner = "root";

  services.nginx.virtualHosts."grafana.kloenk.dev" = {
    locations."/".proxyPass = "http://127.0.0.1:3001/";
    enableACME = true;
    forceSSL = true;
  };

  services.postgresql = {
    ensureDatabases = [ "grafana" ];
    ensureUsers = [{
      name = "grafana";
      ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
    }];
  };

  services.grafana = {
    enable = true;
    domain = "grafana.kloenk.dev";
    provision = {
      enable = true;
      #dashboards = [{ options.path = ./dashboards; }];
    };
    settings = {
      "auth.anonymous".enabled = true;
      server.root_url = "https://grafana.kloenk.dev/";
      server.http_port = 3001;
      database = {
        type = "postgres";
        host = "/run/postgresql";
        user = "grafana";
      };
    };
  };
}