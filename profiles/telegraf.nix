{ lib, pkgs, config, self, ... }:

{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "10s";
        round_interval = true;
        metric_batch_size = 1000;
        metric_buffer_limit = 10000;
        collection_jitter = "5s";
        flush_interval = "10s";
        flush_jitter = "5s";
        hostname = config.networking.hostName;
      };
      outputs.influxdb_v2 = {
        urls = [ "https://influx.kloenk.de" ];
        token = "$INFLUX_TOKEN";
        organization = "kloenk";
        bucket = "default";
      };
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
          collect_cpu_time = false;
          report_active = false;
        };
        disk.ignore_fs =
          [ "tmpfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
        diskio = { };
        mem = { };
        net = { };
        processes = { };
        swap = { };
        system = { };
        ping.urls = [ "1.1.1.1" ];
        ping.binary = "${pkgs.iputils}/bin/ping";
      };
    };
    environmentFiles = [ config.sops.secrets."telegraf/env".path ];
  };

  sops.secrets."telegraf/env" = {
    sopsFile = ../secrets/shared/monitoring.yaml;
    owner = "root";
  };
}
