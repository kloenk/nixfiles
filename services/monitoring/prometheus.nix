{ config, lib, pkgs, self, ... }:

let
  wgHostsAttrs = lib.filterAttrs
    (n: v: v.config.k.wg.net && v.config.services.telegraf.enable)
    self.nixosConfigurations;
  wgServerAttrs = lib.filterAttrs (n: v: !v.config.k.wg.mobile) wgHostsAttrs;
  wgMobileAttrs = lib.filterAttrs (n: v: v.config.k.wg.mobile) wgHostsAttrs;
  wgConfigToTargets = cfgs:
    lib.attrValues
    (lib.mapAttrs (n: v: "${v.config.networking.hostName}.net.kloenk.de") cfgs);
in {
  services.prometheus = {
    enable = true;
    retentionTime = "32d";
    globalConfig = {
      scrape_interval = "30s";
      evaluation_interval = "30s";
    };
    webExternalUrl = "https://prometheus.kloenk.de/";

    scrapeConfigs = [{
      job_name = "telegraf_wg";
      metrics_path = "/metrics";
      scheme = "https";
      static_configs = [
        {
          targets = wgConfigToTargets wgServerAttrs;
          labels.uptype = "server";
        }
        {
          targets = wgConfigToTargets wgMobileAttrs;
          labels.uptype = "mobile";
        }
        {
          targets = [ "telegraf.moodle-usee.kloenk.de" ];
          labels.uptype = "server";
        }
      ];
    }];

    rules = map builtins.toJSON [{
      groups = [{
        name = "infa";
        rules = [
          {
            alert = "InstanceDown";
            expr = "up == 0";
            for = "10m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "WARN - {{ $labels.instance }} down";
              description = ''
                {{ $labels.instance }} has been down for more than 10 minutes.
              '';
            };
          }
          {
            alert = "InstanceDown";
            expr = "up == 0";
            for = "15m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "CRIT - {{ $labels.instance }} down";
              description = ''
                {{ $labels.instance }} has been down for more than 15 minutes.
              '';
            };
          }
          {
            alert = "PingFailed";
            expr = "ping_result_code != 0";
            for = "15m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "CRIT - ping to {{ $labels.url }} failed";
              description = ''
                Ping to {{ $labels.url }} fails for more than 15 minutes.
              '';
            };
          }
          {
            alert = "HighCPU";
            expr = "(cpu_usage_system + cpu_usage_user) > 85";
            for = "30m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "WARN - CPU of {{ $labels.host }} has a high load";
              description = ''
                CPU has a high load for 30min
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "HighCPU";
            expr = "(cpu_usage_system + cpu_usage_user) > 85";
            for = "60m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "CRIT - CPU of {{ $labels.host }} has a high load";
              description = ''
                CPU has a high load for 60min
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "LowStorage";
            expr = ''disk_used_percent{path!="/nix/store"} > 90'';
            for = "5m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "WARN - Disk of {{ $labels.host }} is almost full";
              description = ''
                Disk is almost full
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "LowStorage";
            expr = ''disk_used_percent{path!="/nix/store"} > 95'';
            for = "5m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "CRIT - Disk of {{ $labels.host }} is almost full";
              description = ''
                Disk is almost full
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "LowStoragePredict";
            expr = ''
              predict_linear(disk_free{path!="/nix/store", path!="/boot"}[1h], 5 * 3600) < 0'';
            for = "30m";
            labels = { severity = "warning"; };
            annotations = {
              summary =
                "WARN - Host disk of {{ $labels.host }} will fill in 5 hours";
              description = ''
                Disk will fill in 5 hours at current write rate
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "LowStoragePredict";
            expr = ''
              predict_linear(disk_free{path!="/nix/store", path!="/boot"}[1h], 3 * 3600) < 0'';
            for = "60m";
            labels = { severity = "critical"; };
            annotations = {
              summary =
                "CRIT - Host disk of {{ $labels.host }} will fill in 3 hours";
              description = ''
                Disk will fill in 3 hours at current write rate
                 Value: {{ $value }}'';
            };
          }
          {
            alert = "LowMemory";
            expr = "mem_used_percent > 90";
            for = "5m";
            labels = { severity = "warning"; };
            annotations = {
              summary = "WARN - {{ $labels.host }} is low on system memory";
              description = ''
                {{ $labels.host }} is low on system memory
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "LowMemory";
            expr = "mem_used_percent > 95";
            for = "10m";
            labels = { severity = "critical"; };
            annotations = {
              summary = "CRIT - {{ $labels.host }} is low on system memory";
              description = ''
                {{ $labels.host }} is low on system memory
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "HostSystemdServiceCrashed";
            expr = ''systemd_units_active_code{active="failed"} > 0'';
            for = "5m";
            labels = { severity = "critical"; };
            annotations = {
              summary =
                "CRIT - A systemd unit on {{ $labels.host }} has failed";
              description = ''
                A systemd unit on {{ $labels.host }} has failed
                 Value: {{ $value }}
              '';
            };
          }
          {
            alert = "HttpStatusCodeWrong";
            expr = "http_response_http_response_code != 200";
            for = "5m";
            labels = { severity = "critical"; };
            annotations = {
              summary =
                "CRIT - HTTP service {{ $labels.server }} responded incorrect";
              description = ''
                The HTTP service {{ $labels.service }} responded with {{ $value }} instead of 200.
              '';
            };
          }

        ];
      }];
    }];
  };

  services.nginx.virtualHosts."prometheus.kloenk.de" = {
    locations."/".proxyPass =
      "http://[::1]:${toString config.services.prometheus.port}/";
    enableACME = true;
    forceSSL = true;
    kTLS = true;
  };

  services.vouch-proxy = {
    enable = true;
    servers."prometheus.kloenk.de" = {
      clientId = "prometheus";
      port = 12300;
      environmentFiles =
        [ config.sops.secrets."prometheus/vouch_proxy_env".path ];
    };
  };

  services.grafana.provision.datasources.settings.datasources = [{
    name = "Prometheus";
    type = "prometheus";
    url = "http://[::1]:${toString config.services.prometheus.port}";
    isDefault = true;
  }];

  sops.secrets."prometheus/vouch_proxy_env".owner = "root";
}
