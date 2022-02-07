{ lib, pkgs, config, ... }:

let
  hosts = import ../.. { };

  nginxExtraConfig = ''
    allow 2a01:598:90a2:3090::/64;
    allow 80.187.100.208/32;
    allow 192.168.242.0/24;
    allow 2a0f:4ac4:42:f144::/64;
    allow 2a0f:4ac4:42::/48;

    ${config.services.nginx.virtualHosts."${config.networking.hostName}.kloenk.dev".locations."/node-exporter/".extraConfig}
  '';
in {
  systemd.services.grafana.after = [ "prometheus.service" ];
  systemd.services.grafana.serviceConfig.EnvironmentFile = [ config.sops.secrets."monitoring/grafana/env".path ];
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
    auth.anonymous.enable = true;
    domain = "grafana.kloenk.dev";
    port = 3001;
    rootUrl = "https://grafana.kloenk.dev/";
    provision = {
      enable = true;
      dashboards = [{ options.path = ./dashboards; }];
    };
    extraOptions = {
      AUTH_GITLAB_ENABLED = "true";
      AUTH_GITLAB_TLS_SKIP_VERIFY_INSECURE = "false";
      AUTH_GITLAB_SCOPES = "read_user";
      AUTH_GITLAB_AUTH_URL = "https://cyberchaos.dev/oauth/authorize";
      AUTH_GITLAB_TOKEN_URL = "https://cyberchaos.dev/oauth/token";
      AUTH_GITLAB_API_URL = "https://cyberchaos.dev/api/v4";
      AUTH_GITLAB_ALLOW_SIGN_UP = "true";
      AUTH_GITLAB_ROLE_ATTRIBUTE_PATH = "is_admin && 'Admin' || 'Viewer'";

      DATABASE_TYPE = "postgres";
      DATABASE_HOST = "/run/postgresql";
      DATABASE_USER = "grafana";
    };
  };
}