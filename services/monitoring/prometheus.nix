{ config, lib, pkgs, self, ... }:

let
  vpnHostsAttrs = lib.filterAttrs (n: v:
    v.config.k.vpn.monitoring.enable && v.config.services.telegraf.enable)
    self.nixosConfigurations;
  vpnServerAttrs =
    lib.filterAttrs (n: v: !v.config.k.vpn.monitoring.mobile) vpnHostsAttrs;
  vpnMobileAttrs =
    lib.filterAttrs (n: v: v.config.k.vpn.monitoring.mobile) vpnHostsAttrs;
  vpnConfigToTargets = cfgs:
    lib.attrValues
    (lib.mapAttrs (n: v: "${v.config.networking.hostName}.net.kloenk.dev")
      cfgs);
in {
  services.prometheus = {
    enable = true;
    retentionTime = "90d";
    globalConfig = {
      scrape_interval = "30s";
      evaluation_interval = "30s";
    };
    webExternalUrl = "https://prometheus.kloenk.de/";

    scrapeConfigs = [{
      job_name = "telegraf_vpn";
      metrics_path = "/metrics";
      scheme = "https";
      static_configs = [
        {
          targets = vpnConfigToTargets vpnServerAttrs;
          labels.uptype = "server";
        }
        {
          targets = vpnConfigToTargets vpnMobileAttrs;
          labels.uptype = "mobile";
        }
      ];
    }];

    rules = map builtins.toJSON [{
      groups = [{
        name = "infra";
        rules = import ./prometheus-rules.nix;
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
