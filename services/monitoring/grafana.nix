{ pkgs, lib, config, ... }:

let baseDomain = "grafana.kloenk.de";
in {
  services.postgresql = {
    ensureDatabases = [ "grafana" ];
    ensureUsers = [{
      name = "grafana";
      ensureDBOwnership = true;
    }];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "socket";
        root_url = "https://${baseDomain}";
        domain = baseDomain;
      };
      database = {
        type = "postgres";
        user = "grafana";
        host = "/run/postgresql";
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "Keycloak";
        client_id = "grafana";
        allow_sign_up = true;
        auth_url =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/auth";
        token_url =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/token";
        api_url =
          "https://auth.kloenk.dev/realms/kloenk/protocol/openid-connect/userinfo";
        role_attribute_path =
          "contains(roles[*], 'admin') && 'GrafanaAdmin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
        scopes = "openid profile email roles";
        email_attribute_name = "email:primary";
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [{
          name = "Influx";
          type = "influxdb";
          access = "proxy";
          url = "http://localhost:8086";
        }];
      };
    };
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile =
    [ config.sops.secrets."grafana/env".path ];

  users.users.nginx.extraGroups = [ "grafana" ];
  services.nginx.virtualHosts."grafana.kloenk.de" = {
    locations."/" = {
      proxyPass = "http://unix:${
          toString config.services.grafana.settings.server.socket
        }";
      proxyWebsockets = true;
    };
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };

  sops.secrets."grafana/env".owner = "root";
}
