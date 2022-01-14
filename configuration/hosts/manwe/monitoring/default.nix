{ lib, config, pkgs, ... }:

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

  fileSystems."/var/lib/prometheus2" = {
    device = "/persist/data/prometheus2";
    fsType = "none";
    options = [ "bind" ];
  };
  systemd.services.prometheus.unitConfig.RequiresMountsFor =
    [ "/var/lib/prometheus" ];
  systemd.services.grafana.after = [ "prometheus.service" ];
  systemd.services.grafana.serviceConfig.EnvironmentFile = [ config.petabyte.secrets."grafana-env".path ];
  petabyte.secrets."grafana-env".owner = "root";
  

  services.nginx.virtualHosts."grafana.kloenk.dev" = {
    locations."/".proxyPass = "http://127.0.0.1:3001/";
    enableACME = true;
    forceSSL = true;
  };
  services.nginx.virtualHosts."prometheus.kloenk.dev" = {
    locations."/".proxyPass = "http://127.0.0.1:9090/";
    extraConfig = nginxExtraConfig;
    enableACME = true;
    forceSSL = true;
  };
  services.nginx.virtualHosts."alertmanager.kloenk.dev" = {
    locations."/".proxyPass = "http://127.0.0.1:9093/";
    extraConfig = nginxExtraConfig;
    enableACME = true;
    forceSSL = true;
  };

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.kloenk.dev/";
    listenAddress = "127.0.0.1";
    extraFlags = [ "--cluster.listen-address=" ];
    configuration = {
      global = {
        smtp_from = "alertmanager@kloenk.de";
        smtp_smarthost = "mail.kloenk.de:587";
        smtp_auth_username = "alertmanager@kloenk.de";
        smtp_auth_password = "\${ALERTMANAGER_MAIL_PASSWORD}";
      };
      route = {
        group_by = [ "alertname" "cluster" "service" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "6h";
        receiver = "warning";
        routes = [{
          match = { severity = "critical"; };
          receiver = "critical";
        }];
      };
      inhibit_rules = [{
        source_match = { severity = "critical"; };
        target_match = { severity = "warning"; };
        equal = [ "alertname" "cluster" "service" ];
      }];
      receivers = [
        {
          name = "warning";
          email_configs = [{ to = "me@kloenk.de"; }];
        }
        {
          name = "critical";
          email_configs = [{ to = "me@kloenk.de"; }];
        }
        {
          name = "warning-usee";
          email_configs = [
            { to = "h.behrens@me.com"; }
            { to = "holger.behrens@unterbachersee.de"; }
          ];
        }
        {
          name = "critical-usee";
          email_configs = [
            { to = "h.behrens@me.com"; }
            { to = "holger.behrens@unterbachersee.de"; }
          ];
        }
      ];
    };
  };

  # alertmanager password
  systemd.services.alertmanager.serviceConfig.EnvironmentFile =
    [ config.petabyte.secrets."alertmanager/mail".path ];
  petabyte.secrets."alertmanager/mail".owner = "root";

  services.grafana = {
    enable = true;
    auth.anonymous.enable = true;
    domain = "grafana.kloenk.dev";
    port = 3001;
    rootUrl = "https://grafana.kloenk.dev/";
    provision = {
      enable = true;
      datasources = [{
        type = "prometheus";
        name = "Prometheus";
        url = "http://127.0.0.1:9090/";
        isDefault = true;
      }];
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
    };
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    webExternalUrl = "https://prometheus.kloenk.dev/";
    extraFlags = [
      "--storage.tsdb.retention.size=250GB"
      "--storage.tsdb.retention=1024d"
      "--storage.tsdb.retention.time=1024d"
    ];

    scrapeConfigs = let
      # nginx filtered
      filteredHosts =
        lib.filterAttrs (name: host: host ? prometheusExporters && host ? server && host.server) hosts;
      makeTargets = name: host:
        map (exporter: {
          targets = [ host.host.ip ];
          labels = {
            job = name;
            __metrics_path__ = "/${exporter}/metrics";
          };
        }) host.prometheusExporters;
      targets = lib.concatLists (lib.mapAttrsToList makeTargets filteredHosts);
      targetsFile = pkgs.writeText "targets.json" (builtins.toJSON targets);

      # snmp
      snmp_targets = [
        {
          targets = [ "192.168.178.241" ];
          labels = {
            hostname = "switch-dachboden";
            snmpCommunity = "public";
            mib = "procurve";
          };
        }
        {
          targets = [ "192.168.178.243" ];
          labels = {
            hostname = "switch-studio";
            snmpCommunity = "public";
            mib = "procurve";
          };
        }

        # unifiy (works with procurve??)
        {
          targets = [ "192.168.178.243" ];
          labels = {
            hostname = "switch-pony";
            snmpCommunity = "public";
            mib = "procurve";
          };
        }

        # minecraft (mc-weimar.dev)
        {
          targets = [ "localhost:9225" ];
          labels = {
            server_name = "mc-weimar.dev";
          };
        }
      ];
      snmp_file = pkgs.writeText "snmp_targets.json" (builtins.toJSON snmp_targets);
    in [
      {
        job_name = "dummy";
        file_sd_configs = [{ files = [ (toString targetsFile) ]; }];
      }
      {
        job_name = "snmp-thrain";
        # longer timeouts as it is snmp
        scrape_interval = "120s";
        scrape_timeout = "90s";

        metrics_path = "/snmp";
        params = {
          module = [ "if_mib" ];
          community = [ "public" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "hostname" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "192.168.242.101:9116";
          }
          {
            source_labels = [ "snmpCommunity" ];
            target_label = "__param_community";
          }
          {
            source_labels = [ "mib" ];
            target_label = "__param_module";
          }
        ];

        file_sd_configs = [{ files = [ (toString snmp_file) ]; }];
      }
    ];

    alertmanagers = [{
      scheme = "http";
      static_configs = [{ targets = [ "127.0.0.1:9093" ]; }];
    }];
    rules = map (r: builtins.toJSON r) [{
      groups = [{
        name = "infra";
        rules = let
          serverHosts = lib.filterAttrs (name: host: host.server)
            (lib.filterAttrs (name: host: host ? prometheusExporters) hosts);
          onlineHosts = lib.concatStringsSep "|"
            (lib.mapAttrsToList (name: host: name) serverHosts);
          makeOnlineHost = [
            {
              alert = "InstanceDown";
              expr = ''min(up{job=~"${onlineHosts}"}) by (job) == 0'';
              for = "5m";
              labels = { severity = "warning"; };
              annotations = {
                summary = "{{ $labels.job }} down";
                description =
                  "{{ $labels.job }} has been down for more than 5 minutes.";
              };
            }
            {
              alert = "InstanceDown";
              expr = ''min(up{job=~"${onlineHosts}"}) by (job) == 0'';
              for = "10m";
              labels = { severity = "critical"; };
              annotations = {
                summary = "{{ $labels.job }} down";
                description =
                  "{{ $labels.job }} has been down for more than 10 minutes.";
              };
            }
          ];
        in [
          {
            alert = "InstanceDown-usee";
            expr =
              ''min(up{job=~"bbb-usee|moodle-usee|pve-usee"}) by (job) == 0'';
            for = "5m";
            labels = { severity = "warning-usee"; };
            annotations = {
              summary = "{{ $labels.job }} down";
              description =
                "{{ $labels.job }} has been down for more than 5 minutes.";
            };
          }
          {
            alert = "InstanceDown-usee";
            expr =
              ''min(up{job=~"bbb-usee|moodle-usee|pve-usee"}) by (job) == 0'';
            for = "10m";
            labels = { severity = "critical-usee"; };
            annotations = {
              summary = "{{ $labels.job }} down";
              description =
                "{{ $labels.job }} has been down for more than 10 minutes.";
            };
          }
          {
            alert = "HighLoad";
            expr = ''
              max(node_load5) by (job) > count(node_cpu_seconds_total{mode="system"}) by (job)'';
            for = "1m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "High system load";
              description =
                "{{ $labels.job }} has a high system load (current value: {{ $value }})";
            };
          }
          {
            alert = "HighLoad";
            expr = ''
              max(node_load5) by (job) > 2 * count(node_cpu_seconds_total{mode="system"}) by (job)'';
            for = "1m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "High system load";
              description =
                "{{ $labels.job }} has a very high system load (current value: {{ $value }})";
            };
          }
          {
            alert = "LowMemory";
            expr =
              "((node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes) > 0.75";
            for = "1m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "Low system memory";
              description =
                "{{ $labels.job }} is low on system memory (current value: {{ $value }})";
            };
          }
          {
            alert = "LowMemory";
            expr =
              "((node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes) > 0.9";
            for = "1m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "Low system memory";
              description =
                "{{ $labels.job }} is very low on system memory (current value: {{ $value }})";
            };
          }
        ] ++ makeOnlineHost;
      }];
    }];
  };
}
