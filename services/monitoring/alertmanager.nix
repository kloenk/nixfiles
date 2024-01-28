{ config, ... }:

let alert_message = "{{ .CommonAnnotations.summary }}";
in {
  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.kloenk.de/";
    listenAddress = "127.0.0.1";
    extraFlags = [ "--cluster.listen-address=" ];

    configuration = {
      global = rec {
        smtp_from = "alertmanager@kloenk.de";
        smtp_smarthost = "gimli.kloenk.de:587";
        smtp_auth_username = "no-reply@kloenk.dev";
        smtp_auth_password = "\${ALERTMANAGER_MAIL_PASSWORD}";
      };
      route = {
        group_by = [ "alertname" "service" ];
        group_wait = "15s";
        group_interval = "1m";
        repeat_interval = "12h";
        receiver = "warning";
        routes = [{
          match.severity = "critical";
          receiver = "critical";
        }];
      };
      inhibit_rules = [
        {
          source_match = { severity = "critical"; };
          target_match = { severity = "warning"; };
          equal = [ "alertname" "cluster" "service" ];
        }
        {
          target_match = {
            severity = "critical";
            uptype = "mobile";
            alertname = "InstanceDown";
          };
        }
      ];
      receivers = [
        {
          name = "warning";
          webhook_configs = [{
            http_config.authorization.type = "Bearer";
            http_config.authorization.credentials = "$CYBERCHAOS_CREDENTIALS";
            send_resolved = true;
            url =
              "https://cyberchaos.dev/kloenk/nix/prometheus/alerts/notify.json";
          }];
        }
        {
          name = "critical";
          email_configs = [{
            to = "monitoring@kloenk.de";
            headers.subject = "[ALERT] " + alert_message;
          }];
          webhook_configs = [{
            http_config.authorization.type = "Bearer";
            http_config.authorization.credentials = "$CYBERCHAOS_CREDENTIALS";
            send_resolved = true;
            url =
              "https://cyberchaos.dev/kloenk/nix/prometheus/alerts/notify.json";
          }];
        }
      ];
    };
  };

  services.prometheus.alertmanagers = [{
    scheme = "http";
    static_configs = [{
      targets = [
        "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
      ];
    }];
  }];

  services.nginx.virtualHosts."alertmanager.kloenk.de" = {
    locations."/".proxyPass = "http://127.0.0.1:${
        toString config.services.prometheus.alertmanager.port
      }/";
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };

  services.vouch-proxy = {
    enable = true;
    servers."alertmanager.kloenk.de" = {
      clientId = "prometheus";
      port = 12301;
      environmentFiles =
        [ config.sops.secrets."prometheus/vouch_proxy_env".path ];
    };
  };

  sops.secrets."prometheus/alertmanager_env".owner = "root";
  systemd.services.alertmanager.serviceConfig.EnvironmentFile =
    [ config.sops.secrets."prometheus/alertmanager_env".path ];
}
