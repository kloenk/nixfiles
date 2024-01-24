{ config, lib, pkgs, self, ... }:

let
  wgHostsAttrs = lib.filterAttrs
    (n: v: v.config.k.wg.net && v.config.services.telegraf.enable)
    self.nixosConfigurations;
  wgHosts = lib.attrValues
    (lib.mapAttrs (n: v: "${v.config.networking.hostName}.net.kloenk.de")
      wgHostsAttrs);
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
      static_configs = [{ targets = wgHosts; }];
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
