{ lib, pkgs, config, self, ... }:

{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "20s";
        round_interval = true;
        metric_batch_size = 1000;
        metric_buffer_limit = 10000;
        collection_jitter = "5s";
        flush_interval = "10s";
        flush_jitter = "5s";
        hostname = config.networking.hostName;
      };
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
          collect_cpu_time = false;
          report_active = false;
        };
        disk = {
          ignore_fs = [
            "tmpfs"
            "devtmpfs"
            "devfs"
            "iso9660"
            "overlay"
            "aufs"
            "squashfs"
          ];
          ignore_mount_opts = [ "bind" ];
        };
        diskio = { };
        mem = { };
        net = { ignore_protocol_stats = true; };
        processes = { };
        swap = { };
        system = { };
        systemd_units = { };
      };
      outputs = {
        prometheus_client = {
          listen = "[::1]:9273";
          metric_version = 2;
          expiration_interval = "120s";
          export_timestamp = true;
        };
      };
    };
  };

  services.nginx.virtualHosts = lib.mkIf config.k.wg.net {
    "${config.networking.hostName}.net.kloenk.de" = {
      locations."/metrics" = {
        proxyPass = "http://[::1]:9273/metrics";
        extraConfig = ''
          allow 127.0.0.1/8;
          allow ::1/128;

          allow 192.168.242.0/24;
          allow 2a01:4f8:c013:1a4b:ecba::0/80;

          allow 10.84.32.0/22;
          allow fd4c:1796:6b06::/48;
          deny all;
        '';
      };
    };
  };
}
